from pydantic import BaseModel, Field


class ManutencaoCriar(BaseModel):     # ENTRA no cadastro
    id_equipamento: int = Field(gt=0, description="ID do equipamento")
    id_responsavel: int = Field(gt=0, description="ID do responsável pela manutenção")
    descricao: str = Field(min_length=100)
    status: str = Field(min_length=10)
    tipo: str = Field(min_length=10)
    custo: float = Field(gt=0, description="Custo da manutenção")
    data_abertura: str = Field(pattern=r"^\d{4}-\d{2}-\d{2}$")
    data_conclusao: str | None = Field(default=None, pattern=r"^\d{4}-\d{2}-\d{2}$")

class ManutencaoPublico(BaseModel):      # SAI na resposta
    id: int
    id_equipamento: int
    nome_equipamento: str
    id_responsavel: int
    nome_responsavel: str
    descricao: str
    status: str
    tipo: str
    custo: float
    data_abertura: str
    data_conclusao: str | None = None

class ManutencaoAtualizar(BaseModel):    # ENTRA na edicao, tudo opcional
    id_equipamento: int | None = None
    nome_equipamento: str | None = None
    id_responsavel: int | None = None
    nome_responsavel: str | None = None
    descricao: str | None = None
    status: str | None = None
    tipo: str | None = None
    custo: float | None = None
    data_abertura: str | None = None
    data_conclusao: str | None = None
