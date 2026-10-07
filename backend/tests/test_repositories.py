import pytest

from app.categoria.models import Categoria
from app.equipamentos.models import Equipamento
from app.manutencoes.models import Manutencao
from app.usuarios.repository import UsuarioRepository


class SessaoComFalha:
    def __init__(self):
        self.rollback_count = 0

    def add(self, objeto):
        self.objeto = objeto

    def commit(self):
        raise RuntimeError("falha simulada no banco")

    def rollback(self):
        self.rollback_count += 1


def test_repository_faz_rollback_e_propagaa_falha_de_commit():
    session = SessaoComFalha()
    repository = UsuarioRepository(session)

    with pytest.raises(RuntimeError, match="falha simulada"):
        repository.cadastrar(
            {
                "nome": "Usuário Teste",
                "email": "teste@exemplo.com",
                "senha_hash": "hash",
            }
        )

    assert session.rollback_count == 1
