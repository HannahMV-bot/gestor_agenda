import os

from datetime import datetime, timedelta

from dotenv import load_dotenv
from jose import jwt
import bcrypt


load_dotenv()

SECRET_KEY = os.getenv(
    "SECRET_KEY",
    "gestor_agenda_secret_key_2026",
)

ALGORITHM = "HS256"


def hash_password(password: str) -> str:
    password_bytes = password.encode("utf-8")

    # bcrypt admite máximo 72 bytes
    if len(password_bytes) > 72:
        raise ValueError(
            "La contraseña no puede superar los 72 bytes."
        )

    hashed = bcrypt.hashpw(
        password_bytes,
        bcrypt.gensalt(),
    )

    return hashed.decode("utf-8")


def verify_password(
    password: str,
    hashed_password: str,
) -> bool:

    password_bytes = password.encode("utf-8")

    if len(password_bytes) > 72:
        return False

    return bcrypt.checkpw(
        password_bytes,
        hashed_password.encode("utf-8"),
    )


def create_access_token(user_id: str) -> str:
    expire = datetime.utcnow() + timedelta(
        hours=24
    )

    payload = {
        "sub": user_id,
        "exp": expire,
    }

    return jwt.encode(
        payload,
        SECRET_KEY,
        algorithm=ALGORITHM,
    )