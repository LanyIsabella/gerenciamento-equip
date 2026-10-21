from app.manutencoes.enums import TipoManutencao
from app.manutencoes.policies import (
    FabricaPoliticaTipoManutencao,
    RegrasManutencaoCorretiva,
    RegrasManutencaoPreventiva,
)


def regras_de_teste():
    return {
        "manutencoes": {
            "tipos": {
                "Preventiva": {"custo_minimo": 100},
                "Corretiva": {"custo_minimo": 50, "exige_descricao": True},
            }
        }
    }


def test_factory_method_cria_a_regra_concreta_do_tipo():
    preventiva = FabricaPoliticaTipoManutencao.criar(
        regras_de_teste(), TipoManutencao.PREVENTIVA
    )
    corretiva = FabricaPoliticaTipoManutencao.criar(
        regras_de_teste(), TipoManutencao.CORRETIVA
    )

    assert isinstance(preventiva, RegrasManutencaoPreventiva)
    assert isinstance(corretiva, RegrasManutencaoCorretiva)
    assert preventiva.get("custo_minimo") == 100
    assert corretiva.get("exige_descricao") is True
