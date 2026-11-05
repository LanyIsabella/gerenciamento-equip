import logging

from app.repository_decorators import RepositorioComLog


class RepositorioFalso:
    def buscar_por_id(self, identificador: int):
        return {"id": identificador}


def test_decorator_registra_e_devolve_a_mesma_resposta(caplog):
    repositorio = RepositorioComLog(RepositorioFalso())

    with caplog.at_level(logging.INFO, logger="app.repository_decorators"):
        resposta = repositorio.buscar_por_id(7)

    assert resposta == {"id": 7}
    assert "Repository.buscar_por_id" in caplog.text
