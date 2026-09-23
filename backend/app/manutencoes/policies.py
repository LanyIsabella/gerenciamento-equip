from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING

from app.usuarios.enums import CargoUsuario

from .enums import TipoManutencao
from .erros import ResponsavelManutencaoInvalido

if TYPE_CHECKING:
    from app.usuarios.models import Usuario


class PoliticaManutencao:
    """Strategy de autorização por cargo para manutenções."""

    CARGOS_PERMITIDOS = frozenset(
        {
            CargoUsuario.ADMINISTRADOR,
            CargoUsuario.TECNICO,
        }
    )

    def validar(self, usuario: Usuario | None) -> None:
        if usuario is None or usuario.cargo not in self.CARGOS_PERMITIDOS:
            raise ResponsavelManutencaoInvalido()


def carregar_regras() -> dict:
    caminho = Path(__file__).with_name("regras.json")
    with caminho.open(encoding="utf-8") as arquivo:
        return json.load(arquivo)


class FabricaPoliticaTipoManutencao:
    """Factory Method que seleciona as regras configuradas para um tipo."""

    @classmethod
    def criar(cls, regras: dict, tipo: TipoManutencao | str) -> dict:
        tipo_valor = tipo.value if isinstance(tipo, TipoManutencao) else tipo
        return regras["manutencoes"]["tipos"][tipo_valor]
