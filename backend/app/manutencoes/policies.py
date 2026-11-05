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


# Código anterior, antes da Strategy:
#
# def cadastrar(self, dados, usuario_atual):
#     if usuario_atual is None or usuario_atual.cargo not in {
#         CargoUsuario.ADMINISTRADOR,
#         CargoUsuario.TECNICO,
#     }:
#         raise ResponsavelManutencaoInvalido()
#     return self.repositorio.cadastrar(dados)
#
# A autorização ficava acoplada ao caso de uso. Isso não era funcional para
# vários fluxos de manutenção, pois a mesma regra precisaria ser copiada em
# cadastro, atualização e outros consumidores.
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


# Código anterior, antes da Factory Method:
#
# if dados["tipo"] == TipoManutencao.PREVENTIVA.value:
#     regras = config["manutencoes"]["tipos"]["Preventiva"]
# elif dados["tipo"] == TipoManutencao.CORRETIVA.value:
#     regras = config["manutencoes"]["tipos"]["Corretiva"]
# else:
#     raise RegraManutencaoInvalida("Tipo de manutenção desconhecido")
#
# A seleção e a criação da regra ficavam espalhadas no Service. Isso não era
# funcional para adicionar novos tipos: cada consumidor precisaria ganhar mais
# condicionais e conhecer a forma de configuração de cada regra.
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
