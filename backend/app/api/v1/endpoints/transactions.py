from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.models.user import User
from app.schemas.transaction import (
    TransactionCreate,
    TransactionResponse,
    TransactionSummary,
    TransactionUpdate,
)
from app.services.auth_service import get_current_user
from app.services.transaction_service import TransactionService

router = APIRouter()


@router.get("/", response_model=List[TransactionResponse])
async def list_transactions(
    type: Optional[str] = Query(None, description="'spent' or 'received'"),
    category: Optional[str] = None,
    query: Optional[str] = None,
    limit: int = 100,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await TransactionService.get_all(
        db,
        user_id=current_user.id,
        type_=type,
        category=category,
        query=query,
        limit=limit,
        offset=offset,
    )


@router.get("/summary", response_model=TransactionSummary)
async def get_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await TransactionService.get_summary(db, user_id=current_user.id)


@router.post("/", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
async def create_transaction(
    tx_in: TransactionCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await TransactionService.create(db, user_id=current_user.id, data=tx_in)


@router.get("/{tx_id}", response_model=TransactionResponse)
async def get_transaction(
    tx_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    tx = await TransactionService.get_by_id(db, user_id=current_user.id, tx_id=tx_id)
    if not tx:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return tx


@router.put("/{tx_id}", response_model=TransactionResponse)
async def update_transaction(
    tx_id: str,
    tx_in: TransactionUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    tx = await TransactionService.update(db, user_id=current_user.id, tx_id=tx_id, data=tx_in)
    if not tx:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return tx


@router.delete("/{tx_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_transaction(
    tx_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    deleted = await TransactionService.delete(db, user_id=current_user.id, tx_id=tx_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Transaction not found")
