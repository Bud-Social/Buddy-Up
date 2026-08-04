from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    redis_url: str = 'redis://redis:6379/0'
    model_cache_dir: str = '/models'
    log_level: str = 'INFO'
    api_key: str = ''
    openai_api_key: str = ''
    openai_model: str = 'gpt-4o'
    openai_base_url: str = 'https://api.openai.com/v1'
    meal_plan_corpus_dir: str = '/app/data/meal_plan_corpus'
    nsfw_model: str = 'nudenet'  # 'nudenet' | 'clip' | 'pixel'

    class Config:
        env_prefix = 'AI_'
        env_file = '.env'


settings = Settings()
