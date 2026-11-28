from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.transaction import Transaction
from app.schemas.transaction import TransactionCreate, TransactionSummary, TransactionUpdate


class TransactionService:
    @staticmethod
    async def create(db: AsyncSession, user_id: str, data: TransactionCreate) -> Transaction:
        tx = Transaction(
            user_id=user_id,
            amount=data.amount,
            type=data.type,
            status=data.status,
            category=data.category,
            currency=data.currency,
            note=data.note,
            hashtags=data.hashtags,
            date=data.date or datetime.now(timezone.utc),
        )
        db.add(tx)
        await db.commit()
        await db.refresh(tx)
        return tx

    @staticmethod
    async def get_all(
        db: AsyncSession,
        user_id: str,
        type_: Optional[str] = None,
        category: Optional[str] = None,
        query: Optional[str] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> List[Transaction]:
        stmt = select(Transaction).where(Transaction.user_id == user_id).order_by(desc(Transaction.date))
        
        if type_:
            stmt = stmt.where(Transaction.type == type_)
        if category:
            stmt = stmt.where(Transaction.category == category)
        if query:
            stmt = stmt.where(
                (Transaction.note.ilike(f"%{query}%")) | (Transaction.category.ilike(f"%{query}%"))
            )
        
        stmt = stmt.limit(limit).offset(offset)
        result = await db.execute(stmt)
        return list(result.scalars().all())

    @staticmethod
    async def get_summary(db: AsyncSession, user_id: str) -> TransactionSummary:
        stmt = select(Transaction).where(Transaction.user_id == user_id)
        result = await db.execute(stmt)
        txs = result.scalars().all()

        total_spent = 0.0
        total_received = 0.0
        currency = "EGP"

        for t in txs:
            currency = t.currency
            if t.type == "received":
                total_received += t.amount
            else:
                total_spent += t.amount

        net_remaining = total_received - total_spent if total_received > 0 else 0.0

        return TransactionSummary(
            total_spent=round(total_spent, 2),
            total_received=round(total_received, 2),
            net_remaining=round(net_remaining, 2),
            currency=currency,
            transaction_count=len(txs),
        )

    @staticmethod
    async def get_by_id(db: AsyncSession, user_id: str, tx_id: str) -> Transaction | None:
        stmt = select(Transaction).where(Transaction.user_id == user_id, Transaction.id == tx_id)
        result = await db.execute(stmt)
        return result.scalars().first()

    @staticmethod
    async def update(db: AsyncSession, user_id: str, tx_id: str, data: TransactionUpdate) -> Transaction | None:
        tx = await TransactionService.get_by_id(db, user_id, tx_id)
        if not tx:
            return None
        
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(tx, field, value)
        
        await db.commit()
        await db.refresh(tx)
        return tx

    @staticmethod
    async def delete(db: AsyncSession, user_id: str, tx_id: str) -> bool:
        tx = await TransactionService.get_by_id(db, user_id, tx_id)
        if not tx:
            return false
        await db.delete(tx)
        await db.commit()
        return True
