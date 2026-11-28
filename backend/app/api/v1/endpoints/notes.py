from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.models.user import User
from app.schemas.note import NoteCreate, NoteResponse, NoteUpdate
from app.services.auth_service import get_current_user
from app.services.note_service import NoteService

router = APIRouter()


@router.get("/", response_model=List[NoteResponse])
async def list_notes(
    category: Optional[str] = None,
    query: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    List all personal notes for the current user.
    Pinned notes are returned first, ordered by last updated.
    """
    return await NoteService.get_all(
        db,
        user_id=current_user.id,
        category=category,
        query=query,
    )


@router.post("/", response_model=NoteResponse, status_code=status.HTTP_201_CREATED)
async def create_note(
    note_in: NoteCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new personal note."""
    return await NoteService.create(db, user_id=current_user.id, data=note_in)


@router.get("/{note_id}", response_model=NoteResponse)
async def get_note(
    note_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get single note details."""
    note = await NoteService.get_by_id(db, user_id=current_user.id, note_id=note_id)
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note


@router.put("/{note_id}", response_model=NoteResponse)
async def update_note(
    note_id: str,
    note_in: NoteUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update title, content, category, color or pinned status."""
    note = await NoteService.update(db, user_id=current_user.id, note_id=note_id, data=note_in)
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note


@router.patch("/{note_id}/pin", response_model=NoteResponse)
async def toggle_pin_note(
    note_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Toggle pinned status of a note."""
    note = await NoteService.toggle_pin(db, user_id=current_user.id, note_id=note_id)
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note


@router.delete("/{note_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_note(
    note_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a personal note."""
    deleted = await NoteService.delete(db, user_id=current_user.id, note_id=note_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Note not found")
