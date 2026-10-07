from datetime import date

from app.equipamentos.schemas import EquipamentoResumo
from app.validacao import validar_tamanho_maximo
from app.usuarios.schemas import UsuarioResumo
from pydantic import BaseModel, ConfigDict, field_validator

from .enums import TipoManutencao


class ManutencaoCriar(BaseModel):
    id_equipamento: int
    id_responsavel: int | None = None
    descricao: str
    status: str
    tipo: TipoManutencao
    custo: float
    data_abertura: date
    data_conclusao: date | None = None

    @field_validator("status")
    @classmethod
    def validar_status(cls, valor: str) -> str:
        return validar_tamanho_maximo(valor, "status", 30)

    @field_validator("tipo")
    @classmethod
    def validar_tipo(cls, valor: str) -> str:
        return validar_tamanho_maximo(valor, "tipo", 50)


class ManutencaoAtualizar(BaseModel):
    id_equipamento: int | None = None
    id_responsavel: int | None = None
    descricao: str | None = None
    status: str | None = None
    tipo: TipoManutencao | None = None
    custo: float | None = None
    data_abertura: date | None = None
    data_conclusao: date | None = None

    @field_validator("status")
    @classmethod
    def validar_status(cls, valor: str | None) -> str | None:
        return validar_tamanho_maximo(valor, "status", 30)

    @field_validator("tipo")
    @classmethod
    def validar_tipo(cls, valor: str | None) -> str | None:
        return validar_tamanho_maximo(valor, "tipo", 50)


class ManutencaoEncerrar(BaseModel):
    data_conclusao: date


class ManutencaoPublico(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    id_equipamento: int
    equipamento: EquipamentoResumo
    id_responsavel: int
    responsavel: UsuarioResumo
    descricao: str
    status: str
    tipo: TipoManutencao
    custo: float
    data_abertura: date
    data_conclusao: date | None = None
