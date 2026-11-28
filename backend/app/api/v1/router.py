from fastapi import APIRouter
from app.api.v1.endpoints import ai, auth, meetings, notes, transactions

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(transactions.router, prefix="/transactions", tags=["Transactions & Expenses"])
api_router.include_router(meetings.router, prefix="/meetings", tags=["Calendar & Meetings"])
api_router.include_router(notes.router, prefix="/notes", tags=["Personal Notes"])
api_router.include_router(ai.router, prefix="/ai", tags=["AI Voice Notes Parser"])
