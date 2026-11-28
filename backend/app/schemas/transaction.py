from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class TransactionBase(BaseModel):
    amount: float = Field(..., gt=0, description="Amount must be positive")
    type: str = Field(default="spent", description="'spent' or 'received'")
    status: str = Field(default="Done", description="'Done' or 'Pending'")
    category: str = Field(default="عام ومصروفات")
    currency: str = Field(default="EGP")
    note: Optional[str] = None
    hashtags: Optional[str] = None
    date: Optional[datetime] = None


class TransactionCreate(TransactionBase):
    pass


class TransactionUpdate(BaseModel):
    amount: Optional[float] = None
    type: Optional[str] = None
    status: Optional[str] = None
    category: Optional[str] = None
    currency: Optional[str] = None
    note: Optional[str] = None
    hashtags: Optional[str] = None
    date: Optional[datetime] = None


class TransactionResponse(TransactionBase):
    id: str
    user_id: str
    date: datetime
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class TransactionSummary(BaseModel):
    total_spent: float
    total_received: float
    net_remaining: float
    currency: str = "EGP"
    transaction_count: int
