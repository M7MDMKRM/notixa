from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class MeetingBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    start_time: datetime
    end_time: datetime
    repetition: str = Field(default="none", description="none, daily, weekly, monthly")
    has_alarm: bool = True


class MeetingCreate(MeetingBase):
    pass


class MeetingUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    repetition: Optional[str] = None
    has_alarm: Optional[bool] = None


class MeetingResponse(MeetingBase):
    id: str
    user_id: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
