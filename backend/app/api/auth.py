from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr

from app.core.deps import CurrentUser
from app.core.security import create_access_token

router = APIRouter()


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    id: str
    email: EmailStr


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: CurrentUser) -> UserResponse:
    return UserResponse(id=current_user["id"], email=current_user["email"])


@router.get("/google")
async def google_login() -> dict[str, str]:
    # TODO: Implement Google OAuth redirect
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Google OAuth not configured",
    )


@router.get("/callback")
async def google_callback(code: str) -> TokenResponse:
    # TODO: Implement Google OAuth callback
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Google OAuth not configured",
    )
