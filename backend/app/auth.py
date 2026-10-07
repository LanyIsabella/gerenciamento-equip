from __future__ import annotations

import base64
import hashlib
import hmac
import json
import time

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.usuarios.models import Usuario
from app.usuarios.repository import UsuarioRepository


_bearer = HTTPBearer(auto_error=False)


def _codificar(valor: dict) -> str:
    return base64.urlsafe_b64encode(
        json.dumps(valor, separators=(",", ":")).encode("utf-8")
    ).decode("utf-8").rstrip("=")


def criar_token(usuario_id: int) -> str:
    cabecalho = _codificar({"alg": "HS256", "typ": "JWT"})
    payload = _codificar({"sub": str(usuario_id), "exp": int(time.time()) + 3600})
    mensagem = f"{cabecalho}.{payload}".encode("utf-8")
    assinatura = hmac.new(
        settings.auth_secret.encode("utf-8"), mensagem, hashlib.sha256
    ).digest()
    assinatura_codificada = base64.urlsafe_b64encode(assinatura).decode("utf-8").rstrip("=")
    return f"{cabecalho}.{payload}.{assinatura_codificada}"


def _decodificar_token(token: str) -> int:
    try:
        cabecalho, payload, assinatura = token.split(".")
        mensagem = f"{cabecalho}.{payload}".encode("utf-8")
        assinatura_recebida = base64.urlsafe_b64decode(assinatura + "===")
        assinatura_esperada = hmac.new(
            settings.auth_secret.encode("utf-8"), mensagem, hashlib.sha256
        ).digest()
        if not hmac.compare_digest(assinatura_recebida, assinatura_esperada):
            raise ValueError

        dados = json.loads(base64.urlsafe_b64decode(payload + "===").decode("utf-8"))
        if dados["exp"] < time.time():
            raise ValueError
        return int(dados["sub"])
    except (KeyError, TypeError, ValueError, json.JSONDecodeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido ou expirado",
            headers={"WWW-Authenticate": "Bearer"},
        )


def obter_usuario_atual(
    credenciais: HTTPAuthorizationCredentials | None = Depends(_bearer),
    session: Session = Depends(get_db),
) -> Usuario:
    if credenciais is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de acesso não informado",
            headers={"WWW-Authenticate": "Bearer"},
        )

    usuario = UsuarioRepository(session).buscar_por_id(
        _decodificar_token(credenciais.credentials)
    )
    if usuario is None or not usuario.ativo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário não encontrado ou inativo",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return usuario
