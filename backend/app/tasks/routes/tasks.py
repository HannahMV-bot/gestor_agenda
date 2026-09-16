from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import jwt, JWTError
import os

from app.tasks.schemas.task import (
    TaskCreate,
    TaskUpdate,
)
from app.tasks.services.task_service import (
    create_task,
    get_tasks,
    get_task,
    update_task,
    delete_task,
)

router = APIRouter(
    prefix="/tasks",
    tags=["Tareas"],
)

security = HTTPBearer()

SECRET_KEY = os.getenv(
    "SECRET_KEY",
    "gestor_agenda_secret_key_2026",
)

ALGORITHM = "HS256"


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(
        security
    ),
):
    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
        )

        user_id = payload.get("sub")

        if not user_id:
            raise HTTPException(
                status_code=401,
                detail="Token inválido",
            )

        return user_id

    except JWTError:
        raise HTTPException(
            status_code=401,
            detail="Token inválido o expirado",
        )


@router.post("/")
def create_new_task(
    task: TaskCreate,
    user_id: str = Depends(get_current_user),
):
    task_id = create_task(
        user_id=user_id,
        title=task.title,
        description=task.description,
        date=task.date,
        time=task.time,
        status=task.status,
        priority=task.priority,
    )

    return {
        "message": "Tarea creada correctamente",
        "task_id": task_id,
    }


@router.get("/")
def list_tasks(
    user_id: str = Depends(get_current_user),
):
    return get_tasks(user_id)


@router.get("/{task_id}")
def find_task(
    task_id: str,
    user_id: str = Depends(get_current_user),
):
    task = get_task(
        user_id,
        task_id,
    )

    if not task:
        raise HTTPException(
            status_code=404,
            detail="Tarea no encontrada",
        )

    return task


@router.put("/{task_id}")
def edit_task(
    task_id: str,
    task: TaskUpdate,
    user_id: str = Depends(get_current_user),
):
    updated = update_task(
        user_id=user_id,
        task_id=task_id,
        title=task.title,
        description=task.description,
        date=task.date,
        time=task.time,
        status=task.status,
        priority=task.priority,
    )

    if not updated:
        raise HTTPException(
            status_code=404,
            detail="Tarea no encontrada",
        )

    return {
        "message": "Tarea actualizada correctamente",
    }


@router.delete("/{task_id}")
def remove_task(
    task_id: str,
    user_id: str = Depends(get_current_user),
):
    deleted = delete_task(
        user_id,
        task_id,
    )

    if not deleted:
        raise HTTPException(
            status_code=404,
            detail="Tarea no encontrada",
        )

    return {
        "message": "Tarea eliminada correctamente",
    }