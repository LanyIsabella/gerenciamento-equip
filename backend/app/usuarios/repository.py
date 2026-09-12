from sqlalchemy import select
from sqlalchemy.orm import Session

from .enums import CargoUsuario
from .models import Usuario


class UsuarioRepository:
    def __init__(self, session: Session):
        self.session = session

    def buscar_por_id(self, id_usuario: int) -> Usuario | None:
        return self.session.scalar(select(Usuario).where(Usuario.id == id_usuario))

    def buscar_por_email(self, email: str) -> Usuario | None:
        return self.session.scalar(select(Usuario).where(Usuario.email == email))

    def cadastrar(self, dados: dict) -> Usuario:
        usuario = Usuario(**dados)
        try:
            self.session.add(usuario)
            self.session.commit()
            self.session.refresh(usuario)
        except Exception:
            self.session.rollback()
            raise
        return usuario

    def listar_por_cargo(self, cargo: CargoUsuario) -> list[Usuario]:
        consulta = (
            select(Usuario)
            .where(
                Usuario.cargo == cargo,
                Usuario.ativo.is_(True),
            )
            .order_by(Usuario.nome, Usuario.id)
        )
        return list(self.session.scalars(consulta).all())
