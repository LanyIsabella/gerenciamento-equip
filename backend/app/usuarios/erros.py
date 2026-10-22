from app.erros import ErroDeDominio


class EmailUsuarioJaCadastrado(ErroDeDominio):
    def __init__(self) -> None:
        super().__init__(409, "Já existe um usuário com este e-mail")
