from fastapi import APIRouter, Depends, Query, status

from app.auth import criar_token, obter_usuario_atual

from .dependencias import obter_service
from .enums import CargoUsuario
from .schemas import (LoginRequest, TokenPublico, UsuarioCriar, UsuarioPublico,
                      UsuarioResumo)
from .service import UsuarioService

router = APIRouter(prefix="/usuarios", tags=["Usuários"])


@router.post("/login", response_model=TokenPublico)
def login(dados: LoginRequest, service: UsuarioService = Depends(obter_service)):
    usuario = service.autenticar(dados.email, dados.senha)
    if usuario is None:
        from fastapi import HTTPException

        raise HTTPException(status_code=401, detail="E-mail ou senha inválidos")
    return TokenPublico(access_token=criar_token(usuario.id))


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


@router.get("/eu", response_model=UsuarioPublico)
def eu(usuario=Depends(obter_usuario_atual)):
    return usuario
