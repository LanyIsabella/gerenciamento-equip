from .erros import EquipamentoNaoEncontrado, PatrimonioJaCadastrado
from .policies import PoliticaCriacaoEquipamento
from .validadores import normalizar_patrimonio


class CadastroEquipamentoService:
    def __init__(
        self,
        repositorio,
        politica: PoliticaCriacaoEquipamento | None = None,
    ):
        self.repositorio = repositorio
        self.politica = politica or PoliticaCriacaoEquipamento()

    def cadastrar(self, usuario_atual, **dados):
        self.politica.validar(usuario_atual)
        dados["id_responsavel"] = usuario_atual.id
        dados["patrimonio"] = normalizar_patrimonio(dados["patrimonio"])
        if self.repositorio.buscar_por_patrimonio(dados["patrimonio"]):
            raise PatrimonioJaCadastrado()
        return self.repositorio.cadastrar(dados)


class ListarEquipamentosService:
    def __init__(self, repositorio):
        self.repositorio = repositorio

    def listar(
        self,
        busca: str | None = None,
        id_categoria: int | None = None,
        status: str | None = None,
        id_responsavel: int | None = None,
    ):
        return self.repositorio.listar(
            busca=busca,
            id_categoria=id_categoria,
            status=status,
            id_responsavel=id_responsavel,
        )


class BuscarEquipamentoService:
    def __init__(self, repositorio):
        self.repositorio = repositorio

    def buscar_por_id(self, id_equipamento: int):
        equipamento = self.repositorio.buscar_por_id(id_equipamento)
        if equipamento is None:
            raise EquipamentoNaoEncontrado()
        return equipamento

    def buscar_por_patrimonio(self, patrimonio: str):
        equipamento = self.repositorio.buscar_por_patrimonio(normalizar_patrimonio(patrimonio))
        if equipamento is None:
            raise EquipamentoNaoEncontrado()
        return equipamento


class AtualizarEquipamentoService:
    def __init__(
        self,
        repositorio,
        politica: PoliticaCriacaoEquipamento | None = None,
    ):
        self.repositorio = repositorio
        self.politica = politica or PoliticaCriacaoEquipamento()

    def atualizar(self, id_equipamento: int, dados: dict, usuario_atual):
        equipamento = self.repositorio.buscar_por_id(id_equipamento)
        if equipamento is None:
            raise EquipamentoNaoEncontrado()
        dados = dict(dados)
        self.politica.validar(usuario_atual)
        dados.pop("id_responsavel", None)
        if "patrimonio" in dados:
            dados["patrimonio"] = normalizar_patrimonio(dados["patrimonio"])
            existente = self.repositorio.buscar_por_patrimonio(dados["patrimonio"])
            if existente is not None and existente.id != equipamento.id:
                raise PatrimonioJaCadastrado()
        return self.repositorio.atualizar(equipamento, dados)

    def atualizar_status_por_manutencao(self, id_equipamento: int, status: str):
        equipamento = self.repositorio.buscar_por_id(id_equipamento)
        if equipamento is None:
            raise EquipamentoNaoEncontrado()
        return self.repositorio.atualizar(equipamento, {"status": status})


class ApagarEquipamentoService:
    def __init__(self, repositorio):
        self.repositorio = repositorio

    def apagar(self, id_equipamento: int) -> None:
        equipamento = self.repositorio.buscar_por_id(id_equipamento)
        if equipamento is None:
            raise EquipamentoNaoEncontrado()
        self.repositorio.apagar(equipamento)
