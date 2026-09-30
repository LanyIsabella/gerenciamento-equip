from datetime import date

from .service import AtualizarManutencaoService


class EncerrarManutencaoFacade:
    """Coordena o encerramento da manutenção e a liberação do equipamento."""

    def __init__(self, manutencao_service: AtualizarManutencaoService, equipamento_service):
        self.manutencao_service = manutencao_service
        self.equipamento_service = equipamento_service

    def executar(self, id_manutencao: int, data_conclusao: date):
        manutencao = self.manutencao_service.atualizar(
            id_manutencao,
            {
                "status": "Concluída",
                "data_conclusao": data_conclusao,
            },
        )

        self.equipamento_service.atualizar(
            manutencao.id_equipamento,
            {"status": "Ativo"},
        )

        return manutencao
