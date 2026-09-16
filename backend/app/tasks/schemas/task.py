from pydantic import BaseModel


class TaskCreate(BaseModel):
    title: str
    description: str
    date: str
    time: str
    status: str = "Pendiente"
    priority: str = "Media"


class TaskUpdate(BaseModel):
    title: str
    description: str
    date: str
    time: str
    status: str
    priority: str


class TaskResponse(BaseModel):
    id: str
    user_id: str
    title: str
    description: str
    date: str
    time: str
    status: str
    priority: str