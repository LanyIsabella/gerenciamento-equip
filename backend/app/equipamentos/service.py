from .erros import EquipamentoNaoEncontrado, PatrimonioJaCadastrado


def normalizar_patrimonio(patrimonio: str) -> str:
    valor = patrimonio.strip().upper()
    while valor.startswith("PAT-PAT-"):
        valor = valor[4:]
    return valor if valor.startswith("PAT-") else f"PAT-{valor}"


class CadastroEquipamentoService:
    def __init__(self, repositorio):
        self.repositorio = repositorio

    def cadastrar(self, **dados):
        dados["patrimonio"] = normalizar_patrimonio(dados["patrimonio"])
        if self.repositorio.buscar_por_patrimonio(dados["patrimonio"]):
            raise PatrimonioJaCadastrado()
        return self.repositorio.cadastrar(dados)


class ListarEquipamentosService:
    def __init__(self, repositorio):
        self.repositorio = repositorio

    def listar(self):
        return self.repositorio.listar()


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
    def __init__(self, repositorio):
        self.repositorio = repositorio

    def atualizar(self, id_equipamento: int, dados: dict):
        equipamento = self.repositorio.buscar_por_id(id_equipamento)
        if equipamento is None:
            raise EquipamentoNaoEncontrado()
        dados = dict(dados)
        if "patrimonio" in dados:
            dados["patrimonio"] = normalizar_patrimonio(dados["patrimonio"])
            existente = self.repositorio.buscar_por_patrimonio(dados["patrimonio"])
            if existente is not None and existente.id != equipamento.id:
                raise PatrimonioJaCadastrado()
        return self.repositorio.atualizar(equipamento, dados)


class ApagarEquipamentoService:
    def __init__(self, repositorio):
        self.repositorio = repositorio

    def apagar(self, id_equipamento: int) -> None:
        equipamento = self.repositorio.buscar_por_id(id_equipamento)
        if equipamento is None:
            raise EquipamentoNaoEncontrado()
        self.repositorio.apagar(equipamento)
