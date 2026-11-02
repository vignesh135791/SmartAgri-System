from contextlib import asynccontextmanager
import json

from fastapi import Depends, FastAPI, HTTPException, WebSocket, WebSocketDisconnect, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from .config import get_settings
from .database import create_tables, get_session
from .models import SensorReading, User, YieldRecord
from .recommendations import build_recommendation
from .schemas import (
    LoginRequest,
    SensorReadingCreate,
    SensorReadingResponse,
    TokenResponse,
    UserCreate,
    UserResponse,
    YieldCreate,
    YieldResponse,
    RecommendationResponse,
)
from .security import create_access_token, current_user, hash_password, verify_password


class WebSocketHub:
    def __init__(self) -> None:
        self._clients: set[WebSocket] = set()

    async def connect(self, websocket: WebSocket) -> None:
        await websocket.accept()
        self._clients.add(websocket)

    def disconnect(self, websocket: WebSocket) -> None:
        self._clients.discard(websocket)

    async def broadcast(self, payload: dict) -> None:
        message = json.dumps(payload)
        disconnected: list[WebSocket] = []
        for connection in self._clients:
            try:
                await connection.send_text(message)
            except Exception:
                disconnected.append(connection)
        for connection in disconnected:
            self.disconnect(connection)


websocket_hub = WebSocketHub()


@asynccontextmanager
async def lifespan(_: FastAPI):
    await create_tables()
    yield


app = FastAPI(title="SmartAgri API", version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=get_settings().cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/api/auth/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: UserCreate, session: AsyncSession = Depends(get_session)) -> User:
    existing = await session.scalar(select(User).where(User.email == payload.email))
    if existing is not None:
        raise HTTPException(status_code=409, detail="Email is already registered")
    user = User(
        name=payload.name,
        email=payload.email,
        password_hash=hash_password(payload.password),
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user


@app.post("/api/auth/login", response_model=TokenResponse)
async def login(payload: LoginRequest, session: AsyncSession = Depends(get_session)) -> TokenResponse:
    user = await session.scalar(select(User).where(User.email == payload.email))
    if user is None or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return TokenResponse(access_token=create_access_token(user.id))


@app.get("/api/auth/me", response_model=UserResponse)
async def me(user: User = Depends(current_user)) -> User:
    return user


@app.get("/api/yields", response_model=list[YieldResponse])
async def list_yields(
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> list[YieldRecord]:
    result = await session.scalars(
        select(YieldRecord).where(YieldRecord.owner_id == user.id).order_by(YieldRecord.recorded_date.desc())
    )
    return list(result)


@app.post("/api/yields", response_model=YieldResponse, status_code=status.HTTP_201_CREATED)
async def create_yield(
    payload: YieldCreate,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> YieldRecord:
    record = YieldRecord(owner_id=user.id, **payload.model_dump())
    session.add(record)
    await session.commit()
    await session.refresh(record)
    return record


@app.post("/api/sensors", response_model=SensorReadingResponse, status_code=status.HTTP_201_CREATED)
async def ingest_sensor(
    payload: SensorReadingCreate,
    session: AsyncSession = Depends(get_session),
) -> SensorReading:
    reading = SensorReading(**payload.model_dump())
    session.add(reading)
    await session.commit()
    await session.refresh(reading)
    await websocket_hub.broadcast(
        {"type": "sensor_data", "sensor_data": payload.model_dump(mode="json")}
    )
    return reading


@app.get("/api/recommendations/latest", response_model=RecommendationResponse)
async def latest_recommendation(
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> dict:
    latest_reading = await session.scalar(
        select(SensorReading).order_by(desc(SensorReading.recorded_at)).limit(1)
    )
    yield_result = await session.scalars(
        select(YieldRecord)
        .where(YieldRecord.owner_id == user.id)
        .order_by(desc(YieldRecord.recorded_date))
        .limit(30)
    )
    return build_recommendation(latest_reading, list(yield_result))


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket) -> None:
    await websocket_hub.connect(websocket)
    try:
        while True:
            message = await websocket.receive_text()
            if message == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        websocket_hub.disconnect(websocket)
