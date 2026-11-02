from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: EmailStr
    role: str


class YieldCreate(BaseModel):
    title: str = Field(min_length=1, max_length=150)
    kilograms: float = Field(gt=0)
    acres: float = Field(gt=0)
    recorded_date: date


class YieldResponse(YieldCreate):
    model_config = ConfigDict(from_attributes=True)

    id: int
    yield_per_acre: float
    created_at: datetime


class SensorReadingCreate(BaseModel):
    device_id: str = Field(min_length=1, max_length=120)
    temperature: float
    humidity: float = Field(ge=0, le=100)
    light: float = Field(ge=0)
    soil_moisture: float = Field(ge=0, le=100)
    recorded_at: datetime


class SensorReadingResponse(SensorReadingCreate):
    model_config = ConfigDict(from_attributes=True)

    id: int
