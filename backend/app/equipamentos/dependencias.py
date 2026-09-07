from fastapi import Depends
from sqlalchemy.orm import Session

from app.database import get_db
from .repository import EquipamentoRepository
from .service import (ApagarEquipamentoService, AtualizarEquipamentoService,
                      BuscarEquipamentoService, CadastroEquipamentoService,
                      ListarEquipamentosService)


def obter_repositorio(session: Session = Depends(get_db)) -> EquipamentoRepository:
    return EquipamentoRepository(session)


def obter_service(repositorio: EquipamentoRepository = Depends(obter_repositorio)) -> CadastroEquipamentoService:
    return CadastroEquipamentoService(repositorio)


def obter_service_listagem(repositorio: EquipamentoRepository = Depends(obter_repositorio)) -> ListarEquipamentosService:
    return ListarEquipamentosService(repositorio)


def obter_service_busca(repositorio: EquipamentoRepository = Depends(obter_repositorio)) -> BuscarEquipamentoService:
    return BuscarEquipamentoService(repositorio)


def obter_service_atualizacao(repositorio: EquipamentoRepository = Depends(obter_repositorio)) -> AtualizarEquipamentoService:
    return AtualizarEquipamentoService(repositorio)


def obter_service_exclusao(repositorio: EquipamentoRepository = Depends(obter_repositorio)) -> ApagarEquipamentoService:
    return ApagarEquipamentoService(repositorio)
