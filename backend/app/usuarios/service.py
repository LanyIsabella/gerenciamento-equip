import bcrypt

from .erros import EmailUsuarioJaCadastrado
from .repository import UsuarioRepository


def gerar_hash_senha(senha: str) -> str:
    return bcrypt.hashpw(senha.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verificar_senha(senha: str, senha_hash: str) -> bool:
    try:
        return bcrypt.checkpw(senha.encode("utf-8"), senha_hash.encode("utf-8"))
    except (ValueError, TypeError):
        return False


class UsuarioService:
    def __init__(self, repositorio: UsuarioRepository):
        self.repositorio = repositorio

    def cadastrar(self, dados: dict):
        dados = dict(dados)
        dados["email"] = dados["email"].strip().lower()
        if self.repositorio.buscar_por_email(dados["email"]):
            raise EmailUsuarioJaCadastrado()
        dados["senha_hash"] = gerar_hash_senha(dados.pop("senha"))
        return self.repositorio.cadastrar(dados)

    def listar_por_cargo(self, cargo):
        return self.repositorio.listar_por_cargo(cargo)

    def autenticar(self, email: str, senha: str):
        usuario = self.repositorio.buscar_por_email(email.strip().lower())
        if usuario is None or not usuario.ativo or not verificar_senha(senha, usuario.senha_hash):
            return None
        return usuario
