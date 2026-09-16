from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.auth import router as auth_router
from app.tasks.routes.tasks import router as tasks_router

app = FastAPI(
    title="Gestor de Agenda API",
    description="API REST para el Gestor de Agenda",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/api")
app.include_router(tasks_router, prefix="/api")


@app.get("/")
def root():
    return {
        "message": "Gestor de Agenda API funcionando"
    }