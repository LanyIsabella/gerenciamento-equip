from datetime import date

import pytest

from app.manutencoes.erros import RegraManutencaoInvalida
from app.manutencoes.regras import validar_regras_manutencao


REGRAS_PREVENTIVA = {
    "custo_minimo": 100,
    "exige_data_conclusao_ao_concluir": True,
}

REGRAS_CORRETIVA = {
    "custo_minimo": 50,
    "exige_descricao": True,
}


def dados_base(**alteracoes):
    dados = {
        "tipo": "Preventiva",
        "status": "Pendente",
        "custo": 100,
        "data_abertura": date(2026, 10, 1),
        "data_conclusao": None,
        "descricao": "Revisão do equipamento",
    }
    dados.update(alteracoes)
    return dados


def test_custo_no_limite_minimo_e_aceito():
    validar_regras_manutencao(dados_base(custo=100), REGRAS_PREVENTIVA)


def test_custo_abaixo_do_limite_e_rejeitado():
    with pytest.raises(RegraManutencaoInvalida):
        validar_regras_manutencao(dados_base(custo=99), REGRAS_PREVENTIVA)


def test_data_de_conclusao_nao_pode_ser_anterior_a_abertura():
    with pytest.raises(RegraManutencaoInvalida):
        validar_regras_manutencao(
            dados_base(data_conclusao=date(2026, 9, 30)),
            REGRAS_PREVENTIVA,
        )


def test_manutencao_concluida_exige_data_de_conclusao():
    with pytest.raises(RegraManutencaoInvalida):
        validar_regras_manutencao(
            dados_base(status="Concluída"),
            REGRAS_PREVENTIVA,
        )


def test_corretiva_exige_descricao():
    with pytest.raises(RegraManutencaoInvalida):
        validar_regras_manutencao(
            dados_base(tipo="Corretiva", custo=50, descricao=""),
            REGRAS_CORRETIVA,
        )
