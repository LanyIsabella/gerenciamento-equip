from fastapi import APIRouter, Depends, Query, Response, status

from .dependencias import (obter_service_atualizacao, obter_service_busca,
                           obter_service_cadastro, obter_service_exclusao,
                           obter_service_listagem)
from .schemas import ManutencaoAtualizar, ManutencaoCriar, ManutencaoPublico
from .service import (ApagarManutencaoService, AtualizarManutencaoService,
                      BuscarManutencaoService, CadastroManutencaoService,
                      ListarManutencoesService)

router = APIRouter(prefix="/manutencoes", tags=["Manutenções"])


@router.get("/", response_model=list[ManutencaoPublico])
def listar(
    id_equipamento: int | None = Query(default=None),
    tipo: str | None = Query(default=None),
    status: str | None = Query(default=None),
    service: ListarManutencoesService = Depends(obter_service_listagem),
):
    return service.listar(
        id_equipamento=id_equipamento,
        tipo=tipo,
        status=status,
    )


@router.post("/", response_model=ManutencaoPublico, status_code=201)
def criar(dados: ManutencaoCriar, service: CadastroManutencaoService = Depends(obter_service_cadastro)):
    return service.cadastrar(dados.model_dump())


@router.get("/{id_manutencao}", response_model=ManutencaoPublico)
def buscar(id_manutencao: int, service: BuscarManutencaoService = Depends(obter_service_busca)):
    return service.buscar_por_id(id_manutencao)


@router.patch("/{id_manutencao}", response_model=ManutencaoPublico)
def atualizar(id_manutencao: int, dados: ManutencaoAtualizar, service: AtualizarManutencaoService = Depends(obter_service_atualizacao)):
    return service.atualizar(id_manutencao, dados.model_dump(exclude_unset=True))


@router.delete("/{id_manutencao}", status_code=204)
def apagar(id_manutencao: int, service: ApagarManutencaoService = Depends(obter_service_exclusao)):
    service.apagar(id_manutencao)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
