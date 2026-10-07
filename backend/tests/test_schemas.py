from datetime import date

import pytest
from pydantic import ValidationError

from app.equipamentos.schemas import EquipamentoCriar, EquipamentoAtualizar
from app.manutencoes.enums import TipoManutencao
from app.manutencoes.schemas import ManutencaoCriar, ManutencaoAtualizar


def test_equipamento_normaliza_patrimonio_no_cadastro_e_na_atualizacao():
    criado = EquipamentoCriar(
        nome="Notebook",
        descricao="Uso administrativo",
        data_aquisicao=date(2026, 1, 1),
        patrimonio="pat-1234",
        status="Ativo",
        id_categoria=1,
    )
    atualizado = EquipamentoAtualizar(patrimonio="pat-5678")

    assert criado.patrimonio == "PAT-1234"
    assert atualizado.patrimonio == "PAT-5678"


def test_manutencao_preserva_tipo_enum_e_regras_de_tamanho():
    dados = ManutencaoCriar(
        id_equipamento=1,
        descricao="Troca preventiva",
        status="Pendente",
        tipo="Preventiva",
        custo=100,
        data_abertura=date(2026, 1, 1),
    )

    assert dados.tipo is TipoManutencao.PREVENTIVA

    with pytest.raises(ValidationError, match="status deve ter no máximo"):
        ManutencaoAtualizar(status="x" * 31)
