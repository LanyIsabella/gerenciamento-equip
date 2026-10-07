from pydantic import BaseModel, ConfigDict, field_validator

from .enums import CargoUsuario


class UsuarioCriar(BaseModel):
    nome: str
    email: str
    senha: str
    cargo: CargoUsuario
    ativo: bool = True

    @field_validator("nome")
    @classmethod
    def validar_nome(cls, valor: str) -> str:
        if len(valor) > 100:
            raise ValueError("nome deve ter no máximo 100 caracteres")
        return valor

    @field_validator("email")
    @classmethod
    def validar_email(cls, valor: str) -> str:
        if len(valor) > 255:
            raise ValueError("email deve ter no máximo 255 caracteres")
        return valor.strip().lower()

    @field_validator("senha")
    @classmethod
    def validar_senha(cls, valor: str) -> str:
        valor = valor.strip()
        if len(valor) < 6:
            raise ValueError("senha deve ter pelo menos 6 caracteres")
        if len(valor) > 255:
            raise ValueError("senha deve ter no máximo 255 caracteres")
        return valor


class LoginRequest(BaseModel):
    email: str
    senha: str

    @field_validator("email")
    @classmethod
    def validar_email_login(cls, valor: str) -> str:
        valor = valor.strip().lower()
        if "@" not in valor:
            raise ValueError("informe um e-mail vÃ¡lido")
        return valor


class TokenPublico(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UsuarioPublico(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str
    email: str
    cargo: CargoUsuario
    ativo: bool


class UsuarioResumo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str
    cargo: CargoUsuario

    @field_validator("nome")
    @classmethod
    def validar_nome(cls, valor: str) -> str:
        if len(valor) > 100:
            raise ValueError("nome deve ter no máximo 100 caracteres")
        return valor
