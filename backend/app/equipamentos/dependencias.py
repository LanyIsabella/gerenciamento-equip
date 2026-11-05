from app.database import get_db
from fastapi import Depends
from sqlalchemy.orm import Session

from .repository import EquipamentoRepository
from .service import (
    ApagarEquipamentoService,
    AtualizarEquipamentoService,
    BuscarEquipamentoService,
    CadastroEquipamentoService,
    ListarEquipamentosService,
)


# Código anterior, antes da Injeção de Dependência:
#
# @router.post("/")
# def criar(dados):
#     session = SessionLocal()
#     repositorio = EquipamentoRepository(session)
#     service = CadastroEquipamentoService(repositorio)
#     return service.cadastrar(usuario_atual, **dados.model_dump())
#
# Cada endpoint construía manualmente sessão, Repository e Service. Isso não
# era funcional para trocar implementações ou testar com doubles, pois as
# dependências concretas ficavam presas ao Controller.
def obter_repositorio(session: Session = Depends(get_db)) -> EquipamentoRepository:
    return EquipamentoRepository(session)


def obter_service(
    repositorio: EquipamentoRepository = Depends(obter_repositorio),
) -> CadastroEquipamentoService:
    return CadastroEquipamentoService(repositorio)


def obter_service_listagem(repositorio: EquipamentoRepository = Depends(obter_repositorio)) -> ListarEquipamentosService:
    return ListarEquipamentosService(repositorio)


def obter_service_busca(repositorio: EquipamentoRepository = Depends(obter_repositorio)) -> BuscarEquipamentoService:
    return BuscarEquipamentoService(repositorio)


def obter_service_atualizacao(
    repositorio: EquipamentoRepository = Depends(obter_repositorio),
) -> AtualizarEquipamentoService:
    return AtualizarEquipamentoService(repositorio)


def obter_service_exclusao(repositorio: EquipamentoRepository = Depends(obter_repositorio)) -> ApagarEquipamentoService:
    return ApagarEquipamentoService(repositorio)
