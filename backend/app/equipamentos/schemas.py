from datetime import date
from app.categoria.schemas import CategoriaResumo
from app.usuarios.schemas import UsuarioResumo
from pydantic import BaseModel, ConfigDict, Field


class EquipamentoCriar(BaseModel):
    nome: str = Field(min_length=2, max_length=100)
    descricao: str = Field(min_length=5)
    data_aquisicao: date
    patrimonio: str = Field(min_length=1, max_length=50)
    status: str = Field(min_length=2, max_length=30)
    id_categoria: int = Field(
        gt=0,
        description="ID da categoria do equipamento",
    )
    id_responsavel: int = Field(
        gt=0,
        description="ID do responsável pelo equipamento",
    )


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
    nome: str | None = Field(
        default=None,
        min_length=2,
        max_length=100,
    )
    descricao: str | None = Field(
        default=None,
        min_length=5,
    )
    data_aquisicao: date | None = None
    patrimonio: str | None = Field(
        default=None,
        min_length=1,
        max_length=50,
    )
    status: str | None = Field(
        default=None,
        min_length=2,
        max_length=30,
    )
    id_categoria: int | None = Field(default=None, gt=0)
    id_responsavel: int | None = Field(default=None, gt=0)
