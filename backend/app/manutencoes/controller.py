from fastapi import APIRouter, Depends, Query, Response, status

from app.auth import obter_usuario_atual

from .dependencias import (
    obter_facade_encerramento,
    obter_service_atualizacao,
    obter_service_busca,
    obter_service_cadastro,
    obter_service_exclusao,
    obter_service_listagem,
)
from .enums import TipoManutencao
from .facade import EncerrarManutencaoFacade
from .schemas import (
    ManutencaoAtualizar,
    ManutencaoCriar,
    ManutencaoEncerrar,
    ManutencaoPublico,
)
from .service import (
    ApagarManutencaoService,
    AtualizarManutencaoService,
    BuscarManutencaoService,
    CadastroManutencaoService,
    ListarManutencoesService,
)

router = APIRouter(prefix="/manutencoes", tags=["Manutenções"])


@router.get("/", response_model=list[ManutencaoPublico])
def listar(
    id_equipamento: int | None = Query(default=None),
    tipo: TipoManutencao | None = Query(default=None),
    status: str | None = Query(default=None),
    usuario=Depends(obter_usuario_atual),
    service: ListarManutencoesService = Depends(obter_service_listagem),
):
    return service.listar(
        id_equipamento=id_equipamento,
        tipo=tipo,
        status=status,
        id_responsavel=usuario.id,
    )


@router.post("/", response_model=ManutencaoPublico, status_code=201)
def criar(
    dados: ManutencaoCriar,
    usuario=Depends(obter_usuario_atual),
    service: CadastroManutencaoService = Depends(obter_service_cadastro),
):
    return service.cadastrar(dados.model_dump(exclude_none=True), usuario)


@router.get("/{id_manutencao}", response_model=ManutencaoPublico)
def buscar(id_manutencao: int, service: BuscarManutencaoService = Depends(obter_service_busca)):
    return service.buscar_por_id(id_manutencao)


@router.patch("/{id_manutencao}", response_model=ManutencaoPublico)
def atualizar(
    id_manutencao: int,
    dados: ManutencaoAtualizar,
    usuario=Depends(obter_usuario_atual),
    service: AtualizarManutencaoService = Depends(obter_service_atualizacao),
):
    return service.atualizar(
        id_manutencao,
        dados.model_dump(exclude_unset=True),
        usuario,
    )


@router.patch("/{id_manutencao}/encerrar", response_model=ManutencaoPublico)
def encerrar(
    id_manutencao: int,
    dados: ManutencaoEncerrar,
    usuario=Depends(obter_usuario_atual),
    facade: EncerrarManutencaoFacade = Depends(obter_facade_encerramento),
):
    return facade.executar(id_manutencao, dados.data_conclusao, usuario)


@router.delete("/{id_manutencao}", status_code=204)
def apagar(id_manutencao: int, service: ApagarManutencaoService = Depends(obter_service_exclusao)):
    service.apagar(id_manutencao)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
