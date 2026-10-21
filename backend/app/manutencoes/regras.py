from __future__ import annotations

from datetime import date

from .erros import RegraManutencaoInvalida


def validar_regras_manutencao(
    dados: dict,
    regras_tipo,
) -> None:
    """Valida regras puras de uma manutenção, sem banco ou transporte HTTP."""

    if "custo" in dados and dados["custo"] is None:
        raise RegraManutencaoInvalida(
            "O custo da manutenção não pode ser nulo"
        )

    custo = dados.get("custo")
    if custo is not None and custo < regras_tipo.get("custo_minimo", 0):
        raise RegraManutencaoInvalida(
            "O custo da manutenção não pode ser inferior ao mínimo permitido"
        )

    data_abertura: date | None = dados.get("data_abertura")
    data_conclusao: date | None = dados.get("data_conclusao")
    if (
        data_abertura is not None
        and data_conclusao is not None
        and data_conclusao < data_abertura
    ):
        raise RegraManutencaoInvalida(
            "A data de conclusão não pode ser anterior à data de abertura"
        )

    if (
        dados.get("status") == "Concluída"
        and regras_tipo.get("exige_data_conclusao_ao_concluir", False)
        and not data_conclusao
    ):
        raise RegraManutencaoInvalida(
            "Manutenção concluída exige data de conclusão"
        )

    if regras_tipo.get("exige_descricao", False) and not dados.get("descricao"):
        raise RegraManutencaoInvalida(
            "Manutenção corretiva exige uma descrição do problema"
        )
