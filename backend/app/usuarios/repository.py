from sqlalchemy import select
from sqlalchemy.orm import Session

from .models import Usuario


class UsuarioRepository:
    def __init__(self, session: Session):
        self.session = session

    def buscar_por_id(self, id_usuario: int) -> Usuario | None:
        return self.session.scalar(select(Usuario).where(Usuario.id == id_usuario))
