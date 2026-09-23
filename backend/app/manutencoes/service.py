from .erros import (EquipamentoManutencaoNaoEncontrado,
                     ManutencaoNaoEncontrada,
                     ResponsavelManutencaoNaoEncontrado)
from .policies import PoliticaManutencao


class _BaseManutencaoService:
    def __init__(
        self,
        repositorio,
        equipamento_repositorio,
        usuario_repositorio,
        politica: PoliticaManutencao | None = None,
    ):
        self.repositorio = repositorio
        self.equipamento_repositorio = equipamento_repositorio
        self.usuario_repositorio = usuario_repositorio
        self.politica = politica or PoliticaManutencao()

    def _validar_relacionamentos(self, dados: dict) -> None:
        equipamento = self.equipamento_repositorio.buscar_por_id(dados["id_equipamento"])
        if equipamento is None:
            raise EquipamentoManutencaoNaoEncontrado()
        responsavel = self.usuario_repositorio.buscar_por_id(dados["id_responsavel"])
        if responsavel is None:
            raise ResponsavelManutencaoNaoEncontrado()
        self.politica.validar(responsavel)


class CadastroManutencaoService(_BaseManutencaoService):
    def cadastrar(self, dados: dict):
        self._validar_relacionamentos(dados)
        return self.repositorio.cadastrar(dados)


class ListarManutencoesService(_BaseManutencaoService):
    def listar(
        self,
        id_equipamento: int | None = None,
        tipo: str | None = None,
        status: str | None = None,
    ):
        return self.repositorio.listar(
            id_equipamento=id_equipamento,
            tipo=tipo,
            status=status,
        )


class BuscarManutencaoService(_BaseManutencaoService):
    def buscar_por_id(self, id_manutencao: int):
        manutencao = self.repositorio.buscar_por_id(id_manutencao)
        if manutencao is None:
            raise ManutencaoNaoEncontrada()
        return manutencao


class AtualizarManutencaoService(_BaseManutencaoService):
    def atualizar(self, id_manutencao: int, dados: dict):
        manutencao = self.repositorio.buscar_por_id(id_manutencao)
        if manutencao is None:
            raise ManutencaoNaoEncontrada()
        relacionamentos = {
            "id_equipamento": dados.get("id_equipamento", manutencao.id_equipamento),
            "id_responsavel": dados.get("id_responsavel", manutencao.id_responsavel),
        }
        self._validar_relacionamentos(relacionamentos)
        return self.repositorio.atualizar(manutencao, dados)


class ApagarManutencaoService(_BaseManutencaoService):
    def apagar(self, id_manutencao: int) -> None:
        manutencao = self.repositorio.buscar_por_id(id_manutencao)
        if manutencao is None:
            raise ManutencaoNaoEncontrada()
        self.repositorio.apagar(manutencao)
