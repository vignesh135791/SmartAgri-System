import asyncio
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))
os.environ.setdefault("DATABASE_URL", "mysql+aiomysql://test:test@localhost:3306/smartagri")
os.environ.setdefault("JWT_SECRET", "test-secret-that-is-at-least-32-characters-long")

from app.main import health


def test_health() -> None:
    assert asyncio.run(health()) == {"status": "ok"}
