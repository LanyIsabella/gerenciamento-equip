from fastapi import HTTPException, status


class EmailUsuarioJaCadastrado(HTTPException):
    def __init__(self) -> None:
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            detail="Já existe um usuário com este e-mail",
        )
