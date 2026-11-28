from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.security import decode_access_token, get_password_hash, verify_password
from app.models.user import User
from app.schemas.user import UserCreate

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login", auto_error=False)


class AuthService:
    @staticmethod
    async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
        result = await db.execute(select(User).where(User.email == email))
        return result.scalars().first()

    @staticmethod
    async def get_user_by_id(db: AsyncSession, user_id: str) -> User | None:
        result = await db.execute(select(User).where(User.id == user_id))
        return result.scalars().first()

    @staticmethod
    async def create_user(db: AsyncSession, user_in: UserCreate) -> User:
        existing = await AuthService.get_user_by_email(db, user_in.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this email already exists",
            )
        
        user = User(
            email=user_in.email,
            name=user_in.name,
            hashed_password=get_password_hash(user_in.password),
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
        return user

    @staticmethod
    async def authenticate(db: AsyncSession, email: str, password: str) -> User | None:
        user = await AuthService.get_user_by_email(db, email)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    # 1. Check if token provided and valid
    if token:
        payload = decode_access_token(token)
        if payload and "sub" in payload:
            user = await AuthService.get_user_by_id(db, payload["sub"])
            if user and user.is_active:
                return user

    # 2. For Personal Use Single-User Convenience:
    # If no token is provided, return or create the default owner account (M MÃKRÃM)
    default_email = "M7MDMKRM.0@gmail.com"
    default_user = await AuthService.get_user_by_email(db, default_email)
    if not default_user:
        default_user = User(
            email=default_email,
            name="M MÃKRÃM",
            hashed_password=get_password_hash("nexa_personal_2026"),
        )
        db.add(default_user)
        await db.commit()
        await db.refresh(default_user)
    
    return default_user
