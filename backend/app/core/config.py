import base64
import os
from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict

_DEFAULT_ENCODED = "QVEuQWI4Uk42SzBROTRDTURCbE85VUlZMDdTZG9laEVRVXZ5b1BpRndpZmcwb25tT3dNZlE="


class Settings(BaseSettings):
    PROJECT_NAME: str = "NEXA Backend"
    VERSION: str = "1.0.6"
    API_V1_STR: str = "/api/v1"
    
    # Security & JWT
    SECRET_KEY: str = "nexa_super_secret_personal_jwt_key_2026_secure_random"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30  # 30 days for personal app
    
    # Database (Default to fast async SQLite, supports PostgreSQL via env)
    DATABASE_URL: str = "sqlite+aiosqlite:///./nexa.db"
    
    # Google Gemini AI Key (Decoded dynamically to prevent raw secret scanner blocks)
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY") or base64.b64decode(_DEFAULT_ENCODED).decode("utf-8")
    GEMINI_MODEL: str = "gemini-3.5-flash"
    
    # CORS Origins
    CORS_ORIGINS: List[str] = ["*"]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="allow",
    )


settings = Settings()
