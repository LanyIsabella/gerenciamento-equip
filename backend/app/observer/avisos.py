from __future__ import annotations

import logging
from dataclasses import dataclass
from datetime import date
from typing import Protocol

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class ManutencaoEncerrada:
    """Evento publicado quando uma manutenção passa para concluída."""

    id_manutencao: int
    id_equipamento: int
    data_conclusao: date
    id_responsavel: int


class ObservadorManutencaoEncerrada(Protocol):
    def atualizar(self, evento: ManutencaoEncerrada) -> None:
        ...


class PublicadorManutencaoEncerrada:
    """Notifica interessados sem conhecer seus tipos concretos."""

    def __init__(self, observadores: list[ObservadorManutencaoEncerrada] | None = None):
        self._observadores = list(observadores or [])

    def inscrever(self, observador: ObservadorManutencaoEncerrada) -> None:
        self._observadores.append(observador)

    def publicar(self, evento: ManutencaoEncerrada) -> None:
        for observador in self._observadores:
            observador.atualizar(evento)


class LiberarEquipamentoAoEncerrar:
    """Interessado que libera o equipamento após o encerramento."""

    def __init__(self, equipamento_service):
        self.equipamento_service = equipamento_service

    def atualizar(self, evento: ManutencaoEncerrada) -> None:
        self.equipamento_service.atualizar_status_por_manutencao(
            evento.id_equipamento,
            "Ativo",
        )


class RegistrarEncerramentoNoLog:
    """Interessado que registra o evento para rastreabilidade operacional."""

    def atualizar(self, evento: ManutencaoEncerrada) -> None:
        logger.info(
            "Manutenção encerrada: id_manutencao=%s id_equipamento=%s "
            "data_conclusao=%s id_responsavel=%s",
            evento.id_manutencao,
            evento.id_equipamento,
            evento.data_conclusao.isoformat(),
            evento.id_responsavel,
        )
