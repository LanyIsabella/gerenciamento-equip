from types import SimpleNamespace

from app.equipamentos.service import (
    AtualizarEquipamentoService,
    CadastroEquipamentoService,
)
from app.usuarios.enums import CargoUsuario


class RepositorioEquipamentoFake:
    def __init__(self):
        self.equipamento = SimpleNamespace(id=1)

    def buscar_por_patrimonio(self, patrimonio):
        return None

    def buscar_por_id(self, id_equipamento):
        return self.equipamento if id_equipamento == 1 else None

    def cadastrar(self, dados):
        return dados

    def atualizar(self, equipamento, dados):
        return dados


def usuario_administrador():
    return SimpleNamespace(id=7, cargo=CargoUsuario.ADMINISTRADOR)


def test_cadastro_e_atualizacao_de_equipamento_preservam_o_fluxo():
    repositorio = RepositorioEquipamentoFake()
    usuario = usuario_administrador()
    dados = {"nome": "Notebook", "patrimonio": "pat-1234"}

    cadastro = CadastroEquipamentoService(repositorio)
    atualizacao = AtualizarEquipamentoService(repositorio)

    criado = cadastro.cadastrar(usuario, **dados)
    atualizado = atualizacao.atualizar(1, {"nome": "Notebook novo"}, usuario)

    assert criado["id_responsavel"] == usuario.id
    assert criado["patrimonio"] == "PAT-1234"
    assert atualizado == {"nome": "Notebook novo"}
