from app.erros import ErroDeDominio


class EquipamentoNaoEncontrado(ErroDeDominio):
    def __init__(self) -> None:
        super().__init__(404, "Equipamento não encontrado")


class PatrimonioJaCadastrado(ErroDeDominio):
    def __init__(self) -> None:
        super().__init__(409, "Já existe um equipamento com este patrimônio")


class ResponsavelEquipamentoInvalido(ErroDeDominio):
    def __init__(self) -> None:
        super().__init__(422, "O responsável pelo equipamento deve ter o cargo administrador ou gerente")
