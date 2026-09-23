from .erros import (EquipamentoManutencaoNaoEncontrado,
                     ManutencaoNaoEncontrada,
                     RegraManutencaoInvalida,
                     ResponsavelManutencaoNaoEncontrado)
from .policies import (FabricaPoliticaTipoManutencao, PoliticaManutencao,
                        carregar_regras)


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

    def _validar_relacionamentos(self, dados: dict) -> None:
        equipamento = self.equipamento_repositorio.buscar_por_id(dados["id_equipamento"])
        if equipamento is None:
            raise EquipamentoManutencaoNaoEncontrado()
        responsavel = self.usuario_repositorio.buscar_por_id(dados["id_responsavel"])
        if responsavel is None:
            raise ResponsavelManutencaoNaoEncontrado()
        self.politica.validar(responsavel)

    def _validar_regras_tipo(self, dados: dict) -> None:
        if dados.get("tipo") is None:
            raise RegraManutencaoInvalida(
                "O tipo da manutenção deve ser informado"
            )

        if "custo" in dados and dados["custo"] is None:
            raise RegraManutencaoInvalida(
                "O custo da manutenção não pode ser nulo"
            )

        regras = FabricaPoliticaTipoManutencao.criar(
            self.regras,
            dados["tipo"],
        )

        custo = dados.get("custo")
        if custo is not None and custo < regras.get("custo_minimo", 0):
            raise RegraManutencaoInvalida(
                "O custo da manutenção não pode ser inferior ao mínimo permitido"
            )

        data_abertura = dados.get("data_abertura")
        data_conclusao = dados.get("data_conclusao")
        if (
            data_abertura is not None
            and data_conclusao is not None
            and data_conclusao < data_abertura
        ):
            raise RegraManutencaoInvalida(
                "A data de conclusão não pode ser anterior à data de abertura"
            )

        if (
            dados.get("status") == "Concluída"
            and regras.get("exige_data_conclusao_ao_concluir", False)
            and not data_conclusao
        ):
            raise RegraManutencaoInvalida(
                "Manutenção concluída exige data de conclusão"
            )

        if regras.get("exige_descricao", False) and not dados.get("descricao"):
            raise RegraManutencaoInvalida(
                "Manutenção corretiva exige uma descrição do problema"
            )


class CadastroManutencaoService(_BaseManutencaoService):
    def cadastrar(self, dados: dict):
        self._validar_relacionamentos(dados)
        self._validar_regras_tipo(dados)
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
    def apagar(self, id_manutencao: int) -> None:
        manutencao = self.repositorio.buscar_por_id(id_manutencao)
        if manutencao is None:
            raise ManutencaoNaoEncontrada()
        self.repositorio.apagar(manutencao)
