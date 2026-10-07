from sqlalchemy import select
from app.repository import RepositorioBase

from .enums import CargoUsuario
from .models import Usuario


class UsuarioRepository(RepositorioBase):
    def buscar_por_id(self, id_usuario: int) -> Usuario | None:
        return self.session.scalar(select(Usuario).where(Usuario.id == id_usuario))

    def buscar_por_email(self, email: str) -> Usuario | None:
        return self.session.scalar(select(Usuario).where(Usuario.email == email))

    def cadastrar(self, dados: dict) -> Usuario:
        usuario = Usuario(**dados)
        self.session.add(usuario)
        self._confirmar()
        self.session.refresh(usuario)
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
