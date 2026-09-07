from fastapi import FastAPI

# Importa os modelos para registrar todos os relacionamentos no SQLAlchemy.
from app.categoria.models import Categoria  # noqa: F401
from app.equipamentos.models import Equipamento  # noqa: F401
from app.manutencoes.models import Manutencao  # noqa: F401
from app.usuarios.models import Usuario  # noqa: F401
from .equipamentos import controller as equipamentos_controller
from .manutencoes import controller as manutencoes_controller


app = FastAPI(
    title="EquipControl",
    version="1.0.0",
    description="API para gerenciar equipamentos e suas manutenções.",
)
app.include_router(equipamentos_controller.router)
app.include_router(manutencoes_controller.router)
