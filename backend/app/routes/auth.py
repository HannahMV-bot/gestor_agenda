from fastapi import APIRouter, HTTPException

from app.database import users_collection
from app.models.user import user_model
from app.schemas.user import (
    UserRegister,
    UserLogin,
)
from app.services.auth_service import (
    hash_password,
    verify_password,
    create_access_token,
)


router = APIRouter(
    prefix="/auth",
    tags=["Autenticación"],
)


@router.post("/register")
def register(user: UserRegister):

    existing_user = users_collection.find_one(
        {"email": user.email}
    )

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="El correo ya está registrado",
        )

    hashed_password = hash_password(
        user.password
    )

    new_user = user_model(
        name=user.name,
        last_name=user.last_name,
        email=user.email,
        password=hashed_password,
    )

    result = users_collection.insert_one(
        new_user
    )

    return {
        "message": "Usuario registrado correctamente",
        "user_id": str(result.inserted_id),
    }


@router.post("/login")
def login(user: UserLogin):

    existing_user = users_collection.find_one(
        {"email": user.email}
    )

    if not existing_user:
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    password_correct = verify_password(
        user.password,
        existing_user["password"],
    )

    if not password_correct:
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    token = create_access_token(
        str(existing_user["_id"])
    )

    return {
        "message": "Inicio de sesión exitoso",
        "token": token,
        "user": {
            "id": str(existing_user["_id"]),
            "name": existing_user["name"],
            "last_name": existing_user["last_name"],
            "email": existing_user["email"],
        },
    }