from datetime import datetime


def user_model(
    name: str,
    last_name: str,
    email: str,
    password: str,
):
    return {
        "name": name,
        "last_name": last_name,
        "email": email,
        "password": password,
        "created_at": datetime.utcnow(),
        "active": True,
    }