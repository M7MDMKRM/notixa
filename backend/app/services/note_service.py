from typing import List, Optional
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.note import Note
from app.schemas.note import NoteCreate, NoteUpdate


class NoteService:
    @staticmethod
    async def create(db: AsyncSession, user_id: str, data: NoteCreate) -> Note:
        note = Note(
            user_id=user_id,
            title=data.title,
            content=data.content,
            category=data.category,
            color=data.color,
            is_pinned=data.is_pinned,
        )
        db.add(note)
        await db.commit()
        await db.refresh(note)
        return note

    @staticmethod
    async def get_all(
        db: AsyncSession,
        user_id: str,
        category: Optional[str] = None,
        query: Optional[str] = None,
    ) -> List[Note]:
        # Pinned notes appear first, then by updated_at descending
        stmt = (
            select(Note)
            .where(Note.user_id == user_id)
            .order_by(desc(Note.is_pinned), desc(Note.updated_at))
        )
        if category:
            stmt = stmt.where(Note.category == category)
        if query:
            stmt = stmt.where(
                (Note.title.ilike(f"%{query}%")) | (Note.content.ilike(f"%{query}%"))
            )
        
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_by_id(db: AsyncSession, user_id: str, note_id: str) -> Note | None:
        stmt = select(Note).where(Note.user_id == user_id, Note.id == note_id)
        result = await db.execute(stmt)
        return result.scalars().first()

    @staticmethod
    async def update(db: AsyncSession, user_id: str, note_id: str, data: NoteUpdate) -> Note | None:
        note = await NoteService.get_by_id(db, user_id, note_id)
        if not note:
            return None
        
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(note, field, value)
        
        await db.commit()
        await db.refresh(note)
        return note

    @staticmethod
    async def toggle_pin(db: AsyncSession, user_id: str, note_id: str) -> Note | None:
        note = await NoteService.get_by_id(db, user_id, note_id)
        if not note:
            return None
        
        note.is_pinned = not note.is_pinned
        await db.commit()
        await db.refresh(note)
        return note

    @staticmethod
    async def delete(db: AsyncSession, user_id: str, note_id: str) -> bool:
        note = await NoteService.get_by_id(db, user_id, note_id)
        if not note:
            return False
        await db.delete(note)
        await db.commit()
        return True
