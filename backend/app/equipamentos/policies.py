from __future__ import annotations

from typing import TYPE_CHECKING

from app.usuarios.enums import CargoUsuario

from .erros import ResponsavelEquipamentoInvalido

if TYPE_CHECKING:
    from app.usuarios.models import Usuario


class PoliticaCriacaoEquipamento:
    """Define quem pode ser responsável pela criação de um equipamento.

    A política fica isolada do serviço para que a regra de autorização possa
    ser substituída sem alterar o fluxo de cadastro.
    """

    CARGOS_PERMITIDOS = frozenset(
        {
            CargoUsuario.ADMINISTRADOR,
            CargoUsuario.GERENTE,
        }
    )

    def validar(self, usuario: Usuario | None) -> None:
        if usuario is None or usuario.cargo not in self.CARGOS_PERMITIDOS:
            raise ResponsavelEquipamentoInvalido()
