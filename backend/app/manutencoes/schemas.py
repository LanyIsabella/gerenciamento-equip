from datetime import date

from app.equipamentos.schemas import EquipamentoResumo
from app.usuarios.schemas import UsuarioResumo
from pydantic import BaseModel, ConfigDict, field_validator


class ManutencaoCriar(BaseModel):
    id_equipamento: int
    id_responsavel: int
    descricao: str
    status: str
    tipo: str
    custo: float
    data_abertura: date
    data_conclusao: date | None = None

    @field_validator("status")
    @classmethod
    def validar_status(cls, valor: str) -> str:
        if len(valor) > 30:
            raise ValueError("status deve ter no máximo 30 caracteres")
        return valor

    @field_validator("tipo")
    @classmethod
    def validar_tipo(cls, valor: str) -> str:
        if len(valor) > 50:
            raise ValueError("tipo deve ter no máximo 50 caracteres")
        return valor


class ManutencaoAtualizar(BaseModel):
    id_equipamento: int | None = None
    id_responsavel: int | None = None
    descricao: str | None = None
    status: str | None = None
    tipo: str | None = None
    custo: float | None = None
    data_abertura: date | None = None
    data_conclusao: date | None = None

    @field_validator("status")
    @classmethod
    def validar_status(cls, valor: str | None) -> str | None:
        if valor is not None and len(valor) > 30:
            raise ValueError("status deve ter no máximo 30 caracteres")
        return valor

    @field_validator("tipo")
    @classmethod
    def validar_tipo(cls, valor: str | None) -> str | None:
        if valor is not None and len(valor) > 50:
            raise ValueError("tipo deve ter no máximo 50 caracteres")
        return valor


class ManutencaoPublico(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    id_equipamento: int
    equipamento: EquipamentoResumo
    id_responsavel: int
    responsavel: UsuarioResumo
    descricao: str
    status: str
    tipo: str
    custo: float
    data_abertura: date
    data_conclusao: date | None = None
