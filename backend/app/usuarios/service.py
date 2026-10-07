import hashlib
import hmac
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


def verificar_senha(senha: str, senha_hash: str) -> bool:
    try:
        algoritmo, iteracoes, salt_hex, digest_hex = senha_hash.split("$")
        if algoritmo != "pbkdf2_sha256":
            return False
        digest = hashlib.pbkdf2_hmac(
            "sha256",
            senha.encode("utf-8"),
            bytes.fromhex(salt_hex),
            int(iteracoes),
        )
        return hmac.compare_digest(digest.hex(), digest_hex)
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
