# Importa os modelos para registrar todos os relacionamentos no SQLAlchemy.
from app.categoria.models import Categoria  # noqa: F401
from app.equipamentos.models import Equipamento  # noqa: F401
from app.manutencoes.models import Manutencao  # noqa: F401
from app.usuarios.models import Usuario  # noqa: F401
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .equipamentos import controller as equipamentos_controller
from .erros import ErroDeDominio
from .manutencoes import controller as manutencoes_controller
from .usuarios import controller as usuarios_controller

app = FastAPI(
    title="EquipControl",
    version="1.0.0",
    description="API para gerenciar equipamentos e suas manutenções.",
)


@app.exception_handler(ErroDeDominio)
async def tratar_erro_de_dominio(_: Request, erro: ErroDeDominio):
    return JSONResponse(status_code=erro.status_code, content={"detail": erro.detail})


@app.get("/", tags=["Sistema"])
def raiz():
    return {"sistema": "EquipControl", "status": "online"}

app.add_middleware(
    CORSMiddleware,
    allow_origins=[],
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(equipamentos_controller.router)
app.include_router(manutencoes_controller.router)
app.include_router(usuarios_controller.router)
