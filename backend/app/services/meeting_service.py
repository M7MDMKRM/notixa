from datetime import datetime, timedelta, timezone
from typing import List
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.meeting import Meeting
from app.schemas.meeting import MeetingCreate, MeetingUpdate


class MeetingService:
    @staticmethod
    async def create(db: AsyncSession, user_id: str, data: MeetingCreate) -> Meeting:
        m = Meeting(
            user_id=user_id,
            title=data.title,
            description=data.description,
            start_time=data.start_time,
            end_time=data.end_time,
            repetition=data.repetition,
            has_alarm=data.has_alarm,
        )
        db.add(m)
        await db.commit()
        await db.refresh(m)
        return m

    @staticmethod
    async def get_all(db: AsyncSession, user_id: str) -> List[Meeting]:
        stmt = select(Meeting).where(Meeting.user_id == user_id).order_by(Meeting.start_time.asc())
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_upcoming(db: AsyncSession, user_id: str, hours: int = 48) -> List[Meeting]:
        now = datetime.now(timezone.utc)
        limit_time = now + timedelta(hours=hours)
        
        stmt = (
            select(Meeting)
            .where(Meeting.user_id == user_id, Meeting.start_time >= now, Meeting.start_time <= limit_time)
            .order_by(Meeting.start_time.asc())
        )
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_by_id(db: AsyncSession, user_id: str, meeting_id: str) -> Meeting | None:
        stmt = select(Meeting).where(Meeting.user_id == user_id, Meeting.id == meeting_id)
        result = await db.execute(stmt)
        return result.scalars().first()

    @staticmethod
    async def update(db: AsyncSession, user_id: str, meeting_id: str, data: MeetingUpdate) -> Meeting | None:
        m = await MeetingService.get_by_id(db, user_id, meeting_id)
        if not m:
            return None
        
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(m, field, value)
        
        await db.commit()
        await db.refresh(m)
        return m

    @staticmethod
    async def delete(db: AsyncSession, user_id: str, meeting_id: str) -> bool:
        m = await MeetingService.get_by_id(db, user_id, meeting_id)
        if not m:
            return False
        await db.delete(m)
        await db.commit()
        return True
