from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )

    PROJECT_NAME: str = "{{PROJECT_NAME}}"
    API_V1_PREFIX: str = "/api/v1"

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://{{PROJECT_NAME}}:{{DB_PASS}}@10.10.0.13:5432/{{PROJECT_NAME}}"

    # Redis
    REDIS_URL: str = "redis://10.10.0.13:6379/{{REDIS_DB_NUM}}"

    # Security
    SECRET_KEY: str = "{{SECRET_KEY}}"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    CORS_ORIGINS: list[str] = [
        "http://10.10.0.13:{{FRONTEND_PORT}}",
        "https://{{PROJECT_NAME}}.oklabs.uk",
    ]

    # Google OAuth
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_SECRET: str = ""
    GOOGLE_REDIRECT_URI: str = "https://{{PROJECT_NAME}}-api.oklabs.uk/api/v1/auth/callback"


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
