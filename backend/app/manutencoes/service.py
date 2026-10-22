from .erros import (EquipamentoManutencaoNaoEncontrado,
                     ManutencaoNaoEncontrada,
                     RegraManutencaoInvalida,
                     ResponsavelManutencaoNaoEncontrado)
from .policies import (FabricaPoliticaTipoManutencao, PoliticaManutencao,
                        carregar_regras)
from .regras import validar_regras_manutencao


class _BaseManutencaoService:
    def __init__(
        self,
        repositorio,
        equipamento_repositorio,
        usuario_repositorio,
        politica: PoliticaManutencao | None = None,
        regras: dict | None = None,
    ):
        self.repositorio = repositorio
        self.equipamento_repositorio = equipamento_repositorio
        self.usuario_repositorio = usuario_repositorio
        self.politica = politica or PoliticaManutencao()
        self.regras = regras or carregar_regras()

    def _validar_relacionamentos(self, dados: dict, usuario_atual) -> None:
        equipamento = self.equipamento_repositorio.buscar_por_id(dados["id_equipamento"])
        if equipamento is None:
            raise EquipamentoManutencaoNaoEncontrado()
        responsavel = self.usuario_repositorio.buscar_por_id(dados["id_responsavel"])
        if responsavel is None:
            raise ResponsavelManutencaoNaoEncontrado()
        self.politica.validar(usuario_atual)

    def _validar_regras_tipo(self, dados: dict) -> None:
        if dados.get("tipo") is None:
            raise RegraManutencaoInvalida(
                "O tipo da manutenção deve ser informado"
            )

        regras = FabricaPoliticaTipoManutencao.criar(
            self.regras,
            dados["tipo"],
        )
        validar_regras_manutencao(dados, regras)


class CadastroManutencaoService(_BaseManutencaoService):
    def cadastrar(self, dados: dict, usuario_atual):
        dados = dict(dados)
        self.politica.validar(usuario_atual)
        dados["id_responsavel"] = usuario_atual.id
        self._validar_relacionamentos(dados, usuario_atual)
        self._validar_regras_tipo(dados)
        return self.repositorio.cadastrar(dados)


class ListarManutencoesService(_BaseManutencaoService):
    def listar(
        self,
        id_equipamento: int | None = None,
        tipo: str | None = None,
        status: str | None = None,
        id_responsavel: int | None = None,
    ):
        return self.repositorio.listar(
            id_equipamento=id_equipamento,
            tipo=tipo,
            status=status,
            id_responsavel=id_responsavel,
        )


class BuscarManutencaoService(_BaseManutencaoService):
    def buscar_por_id(self, id_manutencao: int, usuario_atual=None):
        manutencao = self.repositorio.buscar_por_id(id_manutencao)
        if manutencao is None or (
            usuario_atual is not None and manutencao.id_responsavel != usuario_atual.id
        ):
            raise ManutencaoNaoEncontrada()
        return manutencao


class AtualizarManutencaoService(_BaseManutencaoService):
    def atualizar(self, id_manutencao: int, dados: dict, usuario_atual):
        manutencao = self.repositorio.buscar_por_id(id_manutencao)
        if manutencao is None or manutencao.id_responsavel != usuario_atual.id:
            raise ManutencaoNaoEncontrada()
        relacionamentos = {
            "id_equipamento": dados.get("id_equipamento", manutencao.id_equipamento),
            "id_responsavel": dados.get("id_responsavel", manutencao.id_responsavel),
        }
        self._validar_relacionamentos(relacionamentos, usuario_atual)
        dados = dict(dados)
        dados.pop("id_responsavel", None)
        dados_completos = {
            "tipo": manutencao.tipo,
            "status": manutencao.status,
            "descricao": manutencao.descricao,
            "custo": manutencao.custo,
            "data_abertura": manutencao.data_abertura,
            "data_conclusao": manutencao.data_conclusao,
            **dados,
        }
        self._validar_regras_tipo(dados_completos)
        return self.repositorio.atualizar(manutencao, dados)


class ApagarManutencaoService(_BaseManutencaoService):
    def apagar(self, id_manutencao: int, usuario_atual=None) -> None:
        manutencao = self.repositorio.buscar_por_id(id_manutencao)
        if manutencao is None or (
            usuario_atual is not None and manutencao.id_responsavel != usuario_atual.id
        ):
            raise ManutencaoNaoEncontrada()
        self.repositorio.apagar(manutencao)
