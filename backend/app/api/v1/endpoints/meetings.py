from typing import List
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.models.user import User
from app.schemas.meeting import MeetingCreate, MeetingResponse, MeetingUpdate
from app.services.auth_service import get_current_user
from app.services.meeting_service import MeetingService

router = APIRouter()


@router.get("/", response_model=List[MeetingResponse])
async def list_meetings(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await MeetingService.get_all(db, user_id=current_user.id)


@router.get("/upcoming", response_model=List[MeetingResponse])
async def get_upcoming_meetings(
    hours: int = Query(48, ge=1, le=168, description="Hours window, default 48h"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await MeetingService.get_upcoming(db, user_id=current_user.id, hours=hours)


@router.post("/", response_model=MeetingResponse, status_code=status.HTTP_201_CREATED)
async def create_meeting(
    meeting_in: MeetingCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await MeetingService.create(db, user_id=current_user.id, data=meeting_in)


@router.get("/{meeting_id}", response_model=MeetingResponse)
async def get_meeting(
    meeting_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    meeting = await MeetingService.get_by_id(db, user_id=current_user.id, meeting_id=meeting_id)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")
    return meeting


@router.put("/{meeting_id}", response_model=MeetingResponse)
async def update_meeting(
    meeting_id: str,
    meeting_in: MeetingUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    meeting = await MeetingService.update(db, user_id=current_user.id, meeting_id=meeting_id, data=meeting_in)
    if not meeting:
        raise HTTPException(status_code=404, detail="Meeting not found")
    return meeting


@router.delete("/{meeting_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_meeting(
    meeting_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    deleted = await MeetingService.delete(db, user_id=current_user.id, meeting_id=meeting_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Meeting not found")
