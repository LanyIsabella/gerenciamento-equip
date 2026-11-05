from datetime import date

from app.observer.avisos import (
    ManutencaoEncerrada,
    PublicadorManutencaoEncerrada,
)

from .service import AtualizarManutencaoService


# Código anterior, antes da Facade:
#
# @router.patch("/{id_manutencao}/encerrar")
# def encerrar(id_manutencao, dados, manutencao_service, equipamento_service):
#     manutencao = manutencao_service.atualizar(
#         id_manutencao,
#         {"status": "Concluída", "data_conclusao": dados.data_conclusao},
#     )
#     equipamento_service.atualizar(
#         manutencao.id_equipamento,
#         {"status": "Ativo"},
#     )
#     return manutencao
#
# A coordenação de duas entidades ficava no Controller. Isso não era funcional
# para reutilização e testes do caso de uso: a camada HTTP conhecia a sequência
# de operações e poderia deixá-la incompleta em outro ponto de entrada.
class EncerrarManutencaoFacade:
    """Coordena o encerramento da manutenção e a liberação do equipamento."""

    def __init__(
        self,
        manutencao_service: AtualizarManutencaoService,
        publicador: PublicadorManutencaoEncerrada,
    ):
        self.manutencao_service = manutencao_service
        self.publicador = publicador

    def executar(self, id_manutencao: int, data_conclusao: date, usuario_atual):
        manutencao = self.manutencao_service.atualizar(
            id_manutencao,
            {
                "status": "Concluída",
                "data_conclusao": data_conclusao,
            },
            usuario_atual,
        )

        self.publicador.publicar(
            ManutencaoEncerrada(
                id_manutencao=manutencao.id,
                id_equipamento=manutencao.id_equipamento,
                data_conclusao=data_conclusao,
                id_responsavel=usuario_atual.id,
            )
        )

        return manutencao
