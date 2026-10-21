from __future__ import annotations

import json
from dataclasses import dataclass
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


@dataclass(frozen=True)
class RegrasTipoManutencao:
    """Objeto criado pela Factory Method para uma regra de tipo."""

    valores: dict

    @classmethod
    def criar(cls, valores: dict) -> "RegrasTipoManutencao":
        return cls(valores=dict(valores))

    def get(self, chave: str, padrao=None):
        return self.valores.get(chave, padrao)


class RegrasManutencaoPreventiva(RegrasTipoManutencao):
    pass


class RegrasManutencaoCorretiva(RegrasTipoManutencao):
    pass


class FabricaPoliticaTipoManutencao:
    """Factory Method que cria o objeto de regras de cada tipo."""

    TIPOS = {
        TipoManutencao.PREVENTIVA.value: RegrasManutencaoPreventiva,
        TipoManutencao.CORRETIVA.value: RegrasManutencaoCorretiva,
    }

    @classmethod
    def criar(cls, regras: dict, tipo: TipoManutencao | str) -> RegrasTipoManutencao:
        tipo_valor = tipo.value if isinstance(tipo, TipoManutencao) else tipo
        tipo_regras = cls.TIPOS[tipo_valor]
        valores = regras["manutencoes"]["tipos"][tipo_valor]
        return tipo_regras.criar(valores)
