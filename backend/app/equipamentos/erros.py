from fastapi import HTTPException, status


class EquipamentoNaoEncontrado(HTTPException):
    """Erro retornado quando o equipamento informado não existe."""

    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Equipamento não encontrado",
        )

class PatrimonioJaCadastrado(HTTPException):
    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            detail="Já existe um equipamento com este patrimônio",
        )