from datetime import date

from app.categoria.schemas import CategoriaResumo
from app.usuarios.schemas import UsuarioResumo
from pydantic import BaseModel, ConfigDict, field_validator

from .service import normalizar_patrimonio


class EquipamentoCriar(BaseModel):
    nome: str
    descricao: str
    data_aquisicao: date
    patrimonio: str
    status: str
    id_categoria: int
    id_responsavel: int

    @field_validator("nome")
    @classmethod
    def validar_nome(cls, valor: str) -> str:
        if len(valor) > 100:
            raise ValueError("nome deve ter no máximo 100 caracteres")
        return valor

    @field_validator("descricao")
    @classmethod
    def validar_descricao(cls, valor: str) -> str:
        return valor

    @field_validator("patrimonio")
    @classmethod
    def validar_patrimonio(cls, valor: str) -> str:
        valor = normalizar_patrimonio(valor)
        if len(valor) > 50:
            raise ValueError("patrimonio deve ter no máximo 50 caracteres")
        return valor

    @field_validator("status")
    @classmethod
    def validar_status(cls, valor: str) -> str:
        if len(valor) > 30:
            raise ValueError("status deve ter no máximo 30 caracteres")
        return valor


class EquipamentoPublico(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str
    descricao: str
    data_aquisicao: date
    patrimonio: str
    status: str
    categoria: CategoriaResumo
    responsavel: UsuarioResumo


class EquipamentoResumo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str
    patrimonio: str


class EquipamentoAtualizar(BaseModel):
    nome: str | None = None
    descricao: str | None = None
    data_aquisicao: date | None = None
    patrimonio: str | None = None
    status: str | None = None
    id_categoria: int | None = None
    id_responsavel: int | None = None

    @field_validator("nome")
    @classmethod
    def validar_nome(cls, valor: str | None) -> str | None:
        if valor is not None and len(valor) > 100:
            raise ValueError("nome deve ter no máximo 100 caracteres")
        return valor

    @field_validator("descricao")
    @classmethod
    def validar_descricao(cls, valor: str | None) -> str | None:
        return valor

    @field_validator("patrimonio")
    @classmethod
    def validar_patrimonio(cls, valor: str | None) -> str | None:
        if valor is not None:
            valor = normalizar_patrimonio(valor)
        if valor is not None and len(valor) > 50:
            raise ValueError("patrimonio deve ter no máximo 50 caracteres")
        return valor

    @field_validator("status")
    @classmethod
    def validar_status(cls, valor: str | None) -> str | None:
        if valor is not None and len(valor) > 30:
            raise ValueError("status deve ter no máximo 30 caracteres")
        return valor
