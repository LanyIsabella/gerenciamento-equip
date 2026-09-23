from __future__ import annotations

from typing import TYPE_CHECKING

from app.usuarios.enums import CargoUsuario

from .erros import ResponsavelManutencaoInvalido

if TYPE_CHECKING:
    from app.usuarios.models import Usuario


class PoliticaManutencao:
    """Define os cargos autorizados para criar ou alterar manutenções."""

    CARGOS_PERMITIDOS = frozenset(
        {
            CargoUsuario.ADMINISTRADOR,
            CargoUsuario.TECNICO,
        }
    )

    def validar(self, usuario: Usuario | None) -> None:
        if usuario is None or usuario.cargo not in self.CARGOS_PERMITIDOS:
            raise ResponsavelManutencaoInvalido()
