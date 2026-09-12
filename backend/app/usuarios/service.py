import hashlib
import secrets

from .erros import EmailUsuarioJaCadastrado
from .repository import UsuarioRepository


def gerar_hash_senha(senha: str) -> str:
    salt = secrets.token_bytes(16)
    iteracoes = 600_000
    digest = hashlib.pbkdf2_hmac(
        "sha256",
        senha.encode("utf-8"),
        salt,
        iteracoes,
    )
    return f"pbkdf2_sha256${iteracoes}${salt.hex()}${digest.hex()}"


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
