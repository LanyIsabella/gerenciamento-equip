from fastapi import APIRouter, Depends, Query, Response, status

from .dependencias import (obter_service, obter_service_atualizacao,
                           obter_service_busca, obter_service_exclusao,
                           obter_service_listagem)
from .schemas import EquipamentoAtualizar, EquipamentoCriar, EquipamentoPublico
from .service import (ApagarEquipamentoService, AtualizarEquipamentoService,
                      BuscarEquipamentoService, CadastroEquipamentoService,
                      ListarEquipamentosService)

router = APIRouter(prefix="/equipamentos", tags=["Equipamentos"])


@router.get("/", response_model=list[EquipamentoPublico])
def listar(
    busca: str | None = Query(default=None),
    id_categoria: int | None = Query(default=None),
    status: str | None = Query(default=None),
    service: ListarEquipamentosService = Depends(obter_service_listagem),
):
    return service.listar(
        busca=busca,
        id_categoria=id_categoria,
        status=status,
    )


@router.post("/", response_model=EquipamentoPublico, status_code=201)
def criar(dados: EquipamentoCriar, service: CadastroEquipamentoService = Depends(obter_service)):
    return service.cadastrar(**dados.model_dump())


@router.get("/{id_equipamento}", response_model=EquipamentoPublico)
def buscar(id_equipamento: int, service: BuscarEquipamentoService = Depends(obter_service_busca)):
    return service.buscar_por_id(id_equipamento)


@router.patch("/{id_equipamento}", response_model=EquipamentoPublico)
def atualizar(id_equipamento: int, dados: EquipamentoAtualizar, service: AtualizarEquipamentoService = Depends(obter_service_atualizacao)):
    return service.atualizar(id_equipamento, dados.model_dump(exclude_unset=True))


@router.delete("/{id_equipamento}", status_code=204)
def apagar(id_equipamento: int, service: ApagarEquipamentoService = Depends(obter_service_exclusao)):
    service.apagar(id_equipamento)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
