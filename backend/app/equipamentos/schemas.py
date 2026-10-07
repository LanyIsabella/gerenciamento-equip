from datetime import date

from app.categoria.schemas import CategoriaResumo
from app.validacao import validar_tamanho_maximo
from app.usuarios.schemas import UsuarioResumo
from pydantic import BaseModel, ConfigDict, field_validator

from .validadores import normalizar_patrimonio


class EquipamentoCriar(BaseModel):
    nome: str
    descricao: str
    data_aquisicao: date
    patrimonio: str
    status: str
    id_categoria: int
    id_responsavel: int | None = None

    @field_validator("nome")
    @classmethod
    def validar_nome(cls, valor: str) -> str:
        return validar_tamanho_maximo(valor, "nome", 100)

    @field_validator("descricao")
    @classmethod
    def validar_descricao(cls, valor: str) -> str:
        return valor

    @field_validator("patrimonio")
    @classmethod
    def validar_patrimonio(cls, valor: str) -> str:
        valor = normalizar_patrimonio(valor)
        return validar_tamanho_maximo(valor, "patrimonio", 50)

    @field_validator("status")
    @classmethod
    def validar_status(cls, valor: str) -> str:
        return validar_tamanho_maximo(valor, "status", 30)


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
        return validar_tamanho_maximo(valor, "nome", 100)

    @field_validator("descricao")
    @classmethod
    def validar_descricao(cls, valor: str | None) -> str | None:
        return valor

    @field_validator("patrimonio")
    @classmethod
    def validar_patrimonio(cls, valor: str | None) -> str | None:
        if valor is not None:
            valor = normalizar_patrimonio(valor)
        return validar_tamanho_maximo(valor, "patrimonio", 50)

    @field_validator("status")
    @classmethod
    def validar_status(cls, valor: str | None) -> str | None:
        return validar_tamanho_maximo(valor, "status", 30)
