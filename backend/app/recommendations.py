from dataclasses import dataclass

from .models import SensorReading, YieldRecord


@dataclass(frozen=True)
class CropProfile:
    name: str
    min_temperature: float
    max_temperature: float
    min_moisture: float
    max_moisture: float
    min_humidity: float
    max_humidity: float


CROP_PROFILES = (
    CropProfile("Barley", 12, 28, 35, 70, 35, 75),
    CropProfile("Rice", 20, 35, 55, 95, 55, 95),
    CropProfile("Maize", 18, 32, 40, 75, 40, 80),
    CropProfile("Groundnut", 20, 32, 35, 65, 40, 75),
)


def build_recommendation(
    latest_reading: SensorReading | None,
    yield_records: list[YieldRecord],
) -> dict:
    if latest_reading is None:
        return {
            "status": "waiting_for_data",
            "summary": "Add a sensor reading to generate a crop recommendation.",
            "confidence": 0.0,
            "recommendations": [],
            "productivity_insights": _yield_insights(yield_records),
        }

    ranked_crops = sorted(
        (_score_crop(profile, latest_reading) for profile in CROP_PROFILES),
        key=lambda item: item["confidence"],
        reverse=True,
    )
    best_crop = ranked_crops[0]
    return {
        "status": "ready",
        "summary": f"{best_crop['crop']} currently has the strongest environmental fit.",
        "confidence": best_crop["confidence"],
        "recommendations": ranked_crops[:3],
        "productivity_insights": _yield_insights(yield_records),
    }


def _score_crop(profile: CropProfile, reading: SensorReading) -> dict:
    checks = (
        _range_score(reading.temperature, profile.min_temperature, profile.max_temperature),
        _range_score(reading.soil_moisture, profile.min_moisture, profile.max_moisture),
        _range_score(reading.humidity, profile.min_humidity, profile.max_humidity),
    )
    confidence = round(sum(checks) / len(checks), 2)
    reasons = [
        "temperature is within the preferred range"
        if checks[0] >= 0.8
        else "temperature needs monitoring",
        "soil moisture supports growth"
        if checks[1] >= 0.8
        else "adjust irrigation for the preferred soil moisture",
        "humidity is suitable"
        if checks[2] >= 0.8
        else "watch humidity-related crop stress",
    ]
    return {
        "crop": profile.name,
        "confidence": confidence,
        "reasons": reasons,
    }


def _range_score(value: float, minimum: float, maximum: float) -> float:
    if minimum <= value <= maximum:
        return 1.0
    distance = minimum - value if value < minimum else value - maximum
    return max(0.0, 1.0 - distance / max(maximum - minimum, 1))


def _yield_insights(records: list[YieldRecord]) -> list[str]:
    if not records:
        return ["Record at least one harvest to compare productivity trends."]
    average_yield = sum(record.yield_per_acre for record in records) / len(records)
    return [
        f"Average recorded productivity is {average_yield:.1f} kg per acre.",
        f"{len(records)} harvest record(s) are available for comparison.",
    ]
