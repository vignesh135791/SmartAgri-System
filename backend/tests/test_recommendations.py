from datetime import datetime

from app.models import SensorReading
from app.recommendations import build_recommendation


def test_recommendation_uses_sensor_and_productivity_data() -> None:
    reading = SensorReading(
        device_id="demo-device",
        temperature=24,
        humidity=60,
        light=500,
        soil_moisture=55,
        recorded_at=datetime.now(),
    )

    recommendation = build_recommendation(reading, [])

    assert recommendation["status"] == "ready"
    assert recommendation["recommendations"]
    assert recommendation["recommendations"][0]["crop"] == "Barley"


def test_recommendation_explains_missing_sensor_data() -> None:
    recommendation = build_recommendation(None, [])

    assert recommendation["status"] == "waiting_for_data"
    assert recommendation["recommendations"] == []
