from typing import List, Optional
from pydantic import BaseModel
from app.schemas.transaction import TransactionCreate
from app.schemas.meeting import MeetingCreate


class AIExtractRequest(BaseModel):
    raw_text: str


class AIExtractResponse(BaseModel):
    raw_text: str
    transactions: List[TransactionCreate]
    meetings: List[MeetingCreate]
    total_spent: float
    total_received: float
    net_remaining: float
