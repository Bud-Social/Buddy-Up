from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    redis_url: str = 'redis://redis:6379/0'
    model_cache_dir: str = '/models'
    log_level: str = 'INFO'
    api_key: str = ''

    class Config:
        env_prefix = 'AI_'
        env_file = '.env'


settings = Settings()
