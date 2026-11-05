from __future__ import annotations

import logging
from typing import Any

logger = logging.getLogger(__name__)


# Código anterior, quando o log ficava dentro do Repository:
#
# def buscar_por_id(self, id_equipamento: int):
#     logger.info("Repository.buscar_por_id %s", id_equipamento)
#     return self.session.scalar(consulta)
#
# Cada método precisaria repetir o log, misturando persistência e observabilidade.
# Isso não era funcional para aplicar o mesmo comportamento em todos os métodos
# e tornava a remoção do log dependente de editar cada Repository.
class RepositorioComLog:
    """Decorator que registra a operação e repassa a chamada ao Repository."""

    def __init__(self, repositorio: object):
        self.repositorio = repositorio

    def __getattr__(self, nome: str) -> Any:
        membro = getattr(self.repositorio, nome)
        if not callable(membro):
            return membro

        def executar(*args: Any, **kwargs: Any) -> Any:
            logger.info("Repository.%s", nome)
            return membro(*args, **kwargs)

        return executar
