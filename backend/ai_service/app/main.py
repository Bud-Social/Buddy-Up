from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .monitoring import LatencyMiddleware
from .routers import (
    health, food, moderation, embeddings, meal_plans, workout, onboarding,
    health_insights, form_analyzer, feed, metrics, models,
)

app = FastAPI(
    title='BuddyUp AI Service',
    description='AI/ML microservice for Buddy-Up platform',
    version='1.0.0',
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)
app.add_middleware(LatencyMiddleware)

app.include_router(health.router, tags=['health'])
app.include_router(food.router, prefix='/api/v1/food', tags=['food'])
app.include_router(moderation.router, prefix='/api/v1/moderation', tags=['moderation'])
app.include_router(embeddings.router, prefix='/api/v1/embeddings', tags=['embeddings'])
app.include_router(meal_plans.router, prefix='/api/v1/meal-plans', tags=['meal-plans'])
app.include_router(workout.router, prefix='/api/v1/workout', tags=['workout'])
app.include_router(onboarding.router, prefix='/api/v1/onboarding', tags=['onboarding'])
app.include_router(health_insights.router, prefix='/api/v1/health-insights', tags=['health-insights'])
app.include_router(form_analyzer.router, prefix='/api/v1/form-analyzer', tags=['form-analyzer'])
app.include_router(feed.router, prefix='/api/v1/feed', tags=['feed'])
app.include_router(models.router, prefix='/api/v1/models', tags=['models'])
app.include_router(metrics.router, prefix='/api/v1', tags=['metrics'])
