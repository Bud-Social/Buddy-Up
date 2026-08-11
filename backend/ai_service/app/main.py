import asyncio
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .monitoring import LatencyMiddleware
from .routers import (
    health, food, moderation, policy, embeddings, meal_plans, workout, onboarding,
    health_insights, form_analyzer, feed, metrics, models,
    video_caption, summarize, tts, body,
)

logger = logging.getLogger(__name__)

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


async def _idle_unload_loop():
    """Periodically evict heavy HF models untouched for `model_idle_ttl` seconds."""
    from .model_registry import ModelRegistry

    interval = max(60.0, (settings.model_idle_ttl or 900) / 3)
    while True:
        await asyncio.sleep(interval)
        try:
            evicted = ModelRegistry.unload_idle(settings.model_idle_ttl or 900)
            if evicted:
                logger.info('Idle-unload evicted: %s', evicted)
        except Exception as exc:
            logger.warning('Idle-unload pass failed: %s', exc)


@app.on_event('startup')
async def _startup():
    asyncio.get_running_loop().create_task(_idle_unload_loop())


app.include_router(health.router, tags=['health'])
app.include_router(food.router, prefix='/api/v1/food', tags=['food'])
app.include_router(moderation.router, prefix='/api/v1/moderation', tags=['moderation'])
app.include_router(policy.router, prefix='/api/v1/policy', tags=['policy'])
app.include_router(embeddings.router, prefix='/api/v1/embeddings', tags=['embeddings'])
app.include_router(meal_plans.router, prefix='/api/v1/meal-plans', tags=['meal-plans'])
app.include_router(workout.router, prefix='/api/v1/workout', tags=['workout'])
app.include_router(onboarding.router, prefix='/api/v1/onboarding', tags=['onboarding'])
app.include_router(health_insights.router, prefix='/api/v1/health-insights', tags=['health-insights'])
app.include_router(form_analyzer.router, prefix='/api/v1/form-analyzer', tags=['form-analyzer'])
app.include_router(feed.router, prefix='/api/v1/feed', tags=['feed'])
app.include_router(models.router, prefix='/api/v1/models', tags=['models'])
app.include_router(metrics.router, prefix='/api/v1', tags=['metrics'])
app.include_router(video_caption.router, prefix='/api/v1/workout', tags=['workout'])
app.include_router(summarize.router, prefix='/api/v1/summarize', tags=['summarize'])
app.include_router(tts.router, prefix='/api/v1/tts', tags=['tts'])
app.include_router(body.router, prefix='/api/v1/body', tags=['body'])
