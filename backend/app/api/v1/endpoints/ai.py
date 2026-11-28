from fastapi import APIRouter, Depends
from app.models.user import User
from app.schemas.ai import AIExtractRequest, AIExtractResponse
from app.services.ai_service import AIService
from app.services.auth_service import get_current_user

router = APIRouter()


@router.post("/extract", response_model=AIExtractResponse)
async def extract_from_voice(
    request: AIExtractRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Intelligent Conversational Voice Note Parser powered by Gemini 3.5 Flash.
    Extracts structured transactions and meetings from natural Egyptian Arabic dialect.
    """
    return await AIService.extract_from_voice_note(request.raw_text)
