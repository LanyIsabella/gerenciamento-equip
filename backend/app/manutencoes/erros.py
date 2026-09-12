from fastapi import HTTPException, status


class ManutencaoNaoEncontrada(HTTPException):
    """Erro retornado quando a manutenção informada não existe."""

    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Manutenção não encontrada",
        )


class EquipamentoManutencaoNaoEncontrado(HTTPException):
    def __init__(self) -> None:
        super().__init__(status_code=status.HTTP_404_NOT_FOUND, detail="Equipamento não encontrado")


class ResponsavelManutencaoNaoEncontrado(HTTPException):
    def __init__(self) -> None:
        super().__init__(status_code=status.HTTP_404_NOT_FOUND, detail="Usuário responsável não encontrado")


class ResponsavelManutencaoInvalido(HTTPException):
    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="O responsável pela manutenção deve ter o cargo tecnico",
        )
