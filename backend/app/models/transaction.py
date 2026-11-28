import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, DateTime, Float, ForeignKey, String
from sqlalchemy.orm import relationship
from app.core.database import Base


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    
    amount = Column(Float, nullable=False)
    type = Column(String(20), nullable=False, default="spent")  # "spent" or "received"
    status = Column(String(20), nullable=False, default="Done")  # "Done" or "Pending"
    category = Column(String(100), nullable=False, default="عام ومصروفات")
    currency = Column(String(10), nullable=False, default="EGP")
    note = Column(String(500), nullable=True)
    hashtags = Column(String(255), nullable=True)  # Comma-separated or space-separated
    date = Column(DateTime, default=lambda: datetime.now(timezone.utc), index=True)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="transactions")
