from app.database import get_db
from app.equipamentos.repository import EquipamentoRepository
from app.equipamentos.service import AtualizarEquipamentoService
from app.usuarios.repository import UsuarioRepository
from fastapi import Depends
from sqlalchemy.orm import Session

from .facade import EncerrarManutencaoFacade
from .repository import ManutencaoRepository
from .service import (
    ApagarManutencaoService,
    AtualizarManutencaoService,
    BuscarManutencaoService,
    CadastroManutencaoService,
    ListarManutencoesService,
)


def obter_repositorio(session: Session = Depends(get_db)) -> ManutencaoRepository:
    return ManutencaoRepository(session)


def obter_repositorio_equipamentos(session: Session = Depends(get_db)) -> EquipamentoRepository:
    return EquipamentoRepository(session)


def obter_repositorio_usuarios(session: Session = Depends(get_db)) -> UsuarioRepository:
    return UsuarioRepository(session)


def _dependencias(repositorio=Depends(obter_repositorio), equipamento_repositorio=Depends(obter_repositorio_equipamentos), usuario_repositorio=Depends(obter_repositorio_usuarios)):
    return repositorio, equipamento_repositorio, usuario_repositorio


def obter_service_cadastro(deps=Depends(_dependencias)):
    return CadastroManutencaoService(*deps)


def obter_service_listagem(deps=Depends(_dependencias)):
    return ListarManutencoesService(*deps)


def obter_service_busca(deps=Depends(_dependencias)):
    return BuscarManutencaoService(*deps)


def obter_service_atualizacao(deps=Depends(_dependencias)):
    return AtualizarManutencaoService(*deps)


def obter_service_exclusao(deps=Depends(_dependencias)):
    return ApagarManutencaoService(*deps)


def obter_facade_encerramento(deps=Depends(_dependencias)):
    repositorio, equipamento_repositorio, usuario_repositorio = deps
    return EncerrarManutencaoFacade(
        manutencao_service=AtualizarManutencaoService(
            repositorio,
            equipamento_repositorio,
            usuario_repositorio,
        ),
        equipamento_service=AtualizarEquipamentoService(
            equipamento_repositorio,
            usuario_repositorio,
        ),
    )
