#!/usr/bin/env python3
"""Generate deterministic, linked, synthetic CSV data for local bulk testing.

The output deliberately contains no real people or production data.  Every
dataset has a unique primary key and exactly ROW_COUNT records by default.
"""

from __future__ import annotations

import argparse
import csv
from datetime import datetime, timedelta, timezone
from pathlib import Path
import random


ROW_COUNT = 200_000
USER_COUNT = 25_000
START = datetime(2024, 1, 1, tzinfo=timezone.utc)

FIRST_NAMES = ("Amani", "Brielle", "Chidi", "Dalia", "Eli", "Farah", "Gia", "Hassan", "Imani", "Jamal", "Kendi", "Liam")
LAST_NAMES = ("Kamau", "Otieno", "Wanjiku", "Mwangi", "Njeri", "Okafor", "Mensah", "Adebayo", "Khan", "Patel")
CITIES = ("Nairobi", "Mombasa", "Kisumu", "Kampala", "Dar es Salaam", "London", "New York", "Toronto")
GOALS = ("weight_loss", "muscle_gain", "endurance", "mobility", "general_fitness")
WORKOUTS = (
    ("Barbell Back Squat", "strength", "legs", "Builds lower-body strength"),
    ("Romanian Deadlift", "strength", "hamstrings", "Strengthens posterior chain"),
    ("Bench Press", "strength", "chest", "Develops pushing strength"),
    ("Pull-Up", "strength", "back", "Improves upper-body pulling strength"),
    ("Shoulder Press", "strength", "shoulders", "Builds shoulder stability"),
    ("Plank", "core", "core", "Improves trunk stability"),
    ("Running Intervals", "cardio", "full_body", "Raises cardiovascular capacity"),
    ("Cycling", "cardio", "legs", "Builds aerobic endurance"),
    ("Yoga Flow", "mobility", "full_body", "Improves mobility and balance"),
    ("Burpees", "hiit", "full_body", "Improves conditioning and power"),
)
MEALS = (
    ("Overnight Oats", "breakfast", "steady_energy", 420),
    ("Greek Yogurt Berry Bowl", "breakfast", "protein_support", 360),
    ("Chicken Quinoa Bowl", "lunch", "muscle_recovery", 610),
    ("Lentil Vegetable Stew", "lunch", "fiber_support", 480),
    ("Salmon Sweet Potato Plate", "dinner", "heart_health", 670),
    ("Tofu Stir Fry", "dinner", "plant_protein", 530),
    ("Banana Protein Smoothie", "snack", "post_workout_recovery", 310),
    ("Apple Almond Snack", "snack", "satiety", 240),
)
SERVICES = ("feed", "analytics", "workout_planner", "meal_planner", "search", "notifications", "messaging", "marketplace")
EVENTS = ("api_request", "screen_view", "recommendation_served", "search", "notification_sent", "sync_completed")
POST_TYPES = ("workout_update", "meal_share", "progress_photo", "question", "achievement")


def timestamp(index: int, spread_minutes: int = 1_200_000) -> str:
    moment = START + timedelta(minutes=(index * 37) % spread_minutes, seconds=(index * 17) % 60)
    return moment.isoformat().replace("+00:00", "Z")


def writer(path: Path, columns: list[str]):
    handle = path.open("w", newline="", encoding="utf-8")
    return handle, csv.DictWriter(handle, fieldnames=columns, lineterminator="\n")


def generate_users_activity(output: Path, count: int) -> None:
    columns = ["activity_id", "user_id", "user_email", "display_name", "age", "city", "fitness_goal", "activity_type", "activity_value", "unit", "recorded_at"]
    handle, out = writer(output / "users_activity_over_time.csv", columns)
    with handle:
        out.writeheader()
        activity_types = (("steps", "steps"), ("active_minutes", "minutes"), ("calories_burned", "kcal"), ("distance", "km"), ("sleep", "hours"))
        for i in range(1, count + 1):
            user = ((i - 1) % USER_COUNT) + 1
            kind, unit = activity_types[i % len(activity_types)]
            values = {"steps": 2500 + (i * 71) % 15500, "active_minutes": 15 + (i * 13) % 150, "calories_burned": 140 + (i * 29) % 1300, "distance": round(1.2 + ((i * 19) % 128) / 10, 1), "sleep": round(4.5 + ((i * 7) % 45) / 10, 1)}
            first, last = FIRST_NAMES[(user - 1) % len(FIRST_NAMES)], LAST_NAMES[(user - 1) % len(LAST_NAMES)]
            out.writerow({"activity_id": f"UACT{i:07d}", "user_id": f"USR{user:06d}", "user_email": f"user{user:06d}@example.test", "display_name": f"{first} {last}", "age": 18 + user % 53, "city": CITIES[user % len(CITIES)], "fitness_goal": GOALS[user % len(GOALS)], "activity_type": kind, "activity_value": values[kind], "unit": unit, "recorded_at": timestamp(i)})


def generate_workouts(output: Path, count: int) -> None:
    columns = ["workout_id", "workout_name", "category", "body_area", "primary_benefit", "duration_minutes", "sets", "repetitions", "estimated_calories", "difficulty", "created_at"]
    handle, out = writer(output / "workouts_and_benefits.csv", columns)
    with handle:
        out.writeheader()
        levels = ("beginner", "intermediate", "advanced")
        for i in range(1, count + 1):
            name, category, area, benefit = WORKOUTS[(i - 1) % len(WORKOUTS)]
            out.writerow({"workout_id": f"WRK{i:07d}", "workout_name": name, "category": category, "body_area": area, "primary_benefit": benefit, "duration_minutes": 15 + (i * 7) % 76, "sets": 2 + i % 6, "repetitions": 6 + (i * 3) % 20, "estimated_calories": 90 + (i * 23) % 720, "difficulty": levels[i % len(levels)], "created_at": timestamp(i)})


def generate_meals(output: Path, count: int) -> None:
    columns = ["meal_id", "meal_name", "meal_type", "primary_benefit", "calories_kcal", "protein_g", "carbohydrates_g", "fat_g", "dietary_style", "created_at"]
    handle, out = writer(output / "meals_and_benefits.csv", columns)
    with handle:
        out.writeheader()
        styles = ("balanced", "vegetarian", "high_protein", "vegan", "gluten_free")
        for i in range(1, count + 1):
            name, meal_type, benefit, base_calories = MEALS[(i - 1) % len(MEALS)]
            calories = base_calories + (i % 5) * 15
            protein = 12 + (i * 5) % 48
            carbs = 20 + (i * 9) % 78
            fat = 6 + (i * 4) % 29
            out.writerow({"meal_id": f"MEAL{i:07d}", "meal_name": name, "meal_type": meal_type, "primary_benefit": benefit, "calories_kcal": calories, "protein_g": protein, "carbohydrates_g": carbs, "fat_g": fat, "dietary_style": styles[i % len(styles)], "created_at": timestamp(i)})


def generate_service_data(output: Path, count: int) -> None:
    columns = ["service_event_id", "user_id", "service_name", "event_type", "request_id", "status_code", "latency_ms", "platform", "app_version", "recorded_at"]
    handle, out = writer(output / "platform_service_data.csv", columns)
    with handle:
        out.writeheader()
        platforms = ("android", "ios", "web")
        for i in range(1, count + 1):
            status = 200 if i % 29 else 429 if i % 7 else 500
            out.writerow({"service_event_id": f"SVC{i:07d}", "user_id": f"USR{((i * 13 - 1) % USER_COUNT) + 1:06d}", "service_name": SERVICES[i % len(SERVICES)], "event_type": EVENTS[i % len(EVENTS)], "request_id": f"req-{i:08x}", "status_code": status, "latency_ms": 40 + (i * 31) % 2400, "platform": platforms[i % len(platforms)], "app_version": f"{1 + (i // 70000)}.{(i // 1000) % 10}.{i % 20}", "recorded_at": timestamp(i)})


def generate_post_activity(output: Path, count: int) -> None:
    columns = ["post_activity_id", "post_id", "actor_user_id", "author_user_id", "post_type", "activity_type", "dwell_seconds", "source", "occurred_at"]
    handle, out = writer(output / "post_activity_data.csv", columns)
    with handle:
        out.writeheader()
        actions = ("view", "like", "comment", "share", "save", "report")
        sources = ("home_feed", "profile", "search", "notification")
        for i in range(1, count + 1):
            out.writerow({"post_activity_id": f"PACT{i:07d}", "post_id": f"POST{((i * 17 - 1) % 50_000) + 1:06d}", "actor_user_id": f"USR{((i * 11 - 1) % USER_COUNT) + 1:06d}", "author_user_id": f"USR{((i * 23 - 1) % USER_COUNT) + 1:06d}", "post_type": POST_TYPES[i % len(POST_TYPES)], "activity_type": actions[i % len(actions)], "dwell_seconds": 2 + (i * 7) % 298, "source": sources[i % len(sources)], "occurred_at": timestamp(i)})


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path("data/synthetic"))
    parser.add_argument("--rows", type=int, default=ROW_COUNT, help="Rows per CSV (default: 200000)")
    args = parser.parse_args()
    if args.rows < 1:
        parser.error("--rows must be positive")
    args.output.mkdir(parents=True, exist_ok=True)
    for generator in (generate_users_activity, generate_workouts, generate_meals, generate_service_data, generate_post_activity):
        generator(args.output, args.rows)
    print(f"Generated five CSV files with {args.rows:,} rows each in {args.output}")


if __name__ == "__main__":
    main()
