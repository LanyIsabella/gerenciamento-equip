from app.erros import ErroDeDominio


class ManutencaoNaoEncontrada(ErroDeDominio):
    def __init__(self) -> None:
        super().__init__(404, "Manutenção não encontrada")


class EquipamentoManutencaoNaoEncontrado(ErroDeDominio):
    def __init__(self) -> None:
        super().__init__(404, "Equipamento não encontrado")


class ResponsavelManutencaoNaoEncontrado(ErroDeDominio):
    def __init__(self) -> None:
        super().__init__(404, "Usuário responsável não encontrado")


class ResponsavelManutencaoInvalido(ErroDeDominio):
    def __init__(self) -> None:
        super().__init__(422, "O responsável pela manutenção deve ter o cargo administrador ou técnico")


class RegraManutencaoInvalida(ErroDeDominio):
    def __init__(self, detalhe: str) -> None:
        super().__init__(422, detalhe)
