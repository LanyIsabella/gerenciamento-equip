from fastapi import APIRouter, Depends, Query, status

from .dependencias import obter_service
from .enums import CargoUsuario
from .schemas import UsuarioCriar, UsuarioPublico, UsuarioResumo
from .service import UsuarioService

router = APIRouter(prefix="/usuarios", tags=["Usuários"])


@router.post("/", response_model=UsuarioPublico, status_code=status.HTTP_201_CREATED)
def criar(
    dados: UsuarioCriar,
    service: UsuarioService = Depends(obter_service),
):
    return service.cadastrar(dados.model_dump())


@router.get("/", response_model=list[UsuarioResumo])
def listar_por_cargo(
    cargo: CargoUsuario = Query(...),
    service: UsuarioService = Depends(obter_service),
):
    return service.listar_por_cargo(cargo)
