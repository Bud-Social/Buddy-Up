import os

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

    # HuggingFace cache home (persists under the /models volume).
    hf_home: str = '/models/hf'

    # Feature models (CPU-viable INT8 path). Florence-2 uses the HF-converted
    # checkpoint (identical weights) because transformers 5.x needs native
    # support — the original microsoft/Florence-2-base relies on broken remote code.
    caption_model: str = 'florence-community/Florence-2-base'
    clip_model: str = 'openai/clip-vit-base-patch32'
    summarizer_model: str = 'Falconsai/text_summarization'
    tts_model: str = 'microsoft/speecht5_tts'
    tts_vocoder: str = 'microsoft/speecht5_hifigan'
    tts_speaker_dir: str = '/models/speakers'
    tts_default_speaker: str = 'slt'
    tts_sample_rate: int = 22050

    # Max characters accepted for the on-device summarizer (T5 context limit).
    summarizer_max_chars: int = 4000

    # Idle-TTL (seconds) before heavy HF models are unloaded to free RAM.
    model_idle_ttl: int = 900

    # MediaPipe bundles its own TF runtime which conflicts with torch in one
    # process (segfaults). Default OFF so HF/torch features stay reliable;
    # flip on only in a dedicated form-analysis worker without torch.
    enable_mediapipe: bool = False

    class Config:
        env_prefix = 'AI_'
        env_file = '.env'


settings = Settings()

# Make transformers / huggingface_hub honour our persistent cache dir.
os.environ.setdefault('HF_HOME', settings.hf_home)
os.environ.setdefault('HF_HUB_CACHE', os.path.join(settings.hf_home, 'hub'))
