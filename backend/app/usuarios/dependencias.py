from fastapi import Depends
from sqlalchemy.orm import Session

from app.database import get_db

from .repository import UsuarioRepository
from .service import UsuarioService


def obter_repositorio(session: Session = Depends(get_db)) -> UsuarioRepository:
    return UsuarioRepository(session)


def obter_service(
    repositorio: UsuarioRepository = Depends(obter_repositorio),
) -> UsuarioService:
    return UsuarioService(repositorio)
