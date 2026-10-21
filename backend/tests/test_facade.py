from datetime import date
from types import SimpleNamespace

from app.manutencoes.facade import EncerrarManutencaoFacade
from app.observer.avisos import (
    LiberarEquipamentoAoEncerrar,
    ManutencaoEncerrada,
    PublicadorManutencaoEncerrada,
    RegistrarEncerramentoNoLog,
)


class ManutencaoServiceFake:
    def __init__(self):
        self.chamadas = []

    def atualizar(self, id_manutencao, dados, usuario_atual):
        self.chamadas.append((id_manutencao, dados, usuario_atual))
        return SimpleNamespace(id=id_manutencao, id_equipamento=42, status=dados["status"])


class ObservadorFake:
    def __init__(self):
        self.chamadas = []

    def atualizar(self, evento):
        self.chamadas.append(evento)


def test_facade_encerramento_coordena_manutencao_e_equipamento():
    manutencao_service = ManutencaoServiceFake()
    observador = ObservadorFake()
    publicador = PublicadorManutencaoEncerrada([observador])
    facade = EncerrarManutencaoFacade(manutencao_service, publicador)
    usuario = SimpleNamespace(id=7)
    data_conclusao = date(2026, 10, 21)

    resultado = facade.executar(9, data_conclusao, usuario)

    assert resultado.id == 9
    assert manutencao_service.chamadas == [
        (9, {"status": "Concluída", "data_conclusao": data_conclusao}, usuario)
    ]
    assert observador.chamadas == [
        ManutencaoEncerrada(
            id_manutencao=9,
            id_equipamento=42,
            data_conclusao=data_conclusao,
            id_responsavel=7,
        )
    ]


def test_publicador_notifica_novo_interessado_sem_alterar_o_publicador():
    primeiro = ObservadorFake()
    segundo = ObservadorFake()
    publicador = PublicadorManutencaoEncerrada([primeiro])
    evento = ManutencaoEncerrada(9, 42, date(2026, 10, 21), 7)

    publicador.inscrever(segundo)
    publicador.publicar(evento)

    assert primeiro.chamadas == [evento]
    assert segundo.chamadas == [evento]


def test_observadores_reais_liberam_e_registram_o_encerramento(caplog):
    equipamento_service = SimpleNamespace(atualizar_status_por_manutencao=lambda *args: args)
    evento = ManutencaoEncerrada(9, 42, date(2026, 10, 21), 7)

    LiberarEquipamentoAoEncerrar(equipamento_service).atualizar(evento)
    with caplog.at_level("INFO"):
        RegistrarEncerramentoNoLog().atualizar(evento)

    assert "Manutenção encerrada" in caplog.text
