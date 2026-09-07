from datetime import date

from app.equipamentos.schemas import EquipamentoResumo
from app.usuarios.schemas import UsuarioResumo
from pydantic import BaseModel, ConfigDict, Field


class ManutencaoCriar(BaseModel):
    id_equipamento: int = Field(gt=0, description="ID do equipamento")
    id_responsavel: int = Field(gt=0, description="ID do responsável pela manutenção")
    descricao: str = Field(min_length=100)
    status: str = Field(min_length=10, max_length=30)
    tipo: str = Field(min_length=10, max_length=50)
    custo: float = Field(gt=0)
    data_abertura: date
    data_conclusao: date | None = None


class ManutencaoAtualizar(BaseModel):
    id_equipamento: int | None = Field(default=None, gt=0)
    id_responsavel: int | None = Field(default=None, gt=0)
    descricao: str | None = Field(default=None, min_length=100)
    status: str | None = Field(default=None, min_length=10, max_length=30)
    tipo: str | None = Field(default=None, min_length=10, max_length=50)
    custo: float | None = Field(default=None, gt=0)
    data_abertura: date | None = None
    data_conclusao: date | None = None


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
