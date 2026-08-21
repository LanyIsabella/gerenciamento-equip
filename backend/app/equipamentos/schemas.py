from pydantic import BaseModel, Field


class EquipamentoCriar(BaseModel):     # ENTRA no cadastro
    nome: str = Field(min_length=40)
    descricao: str = Field(min_length=100)
    data_aquisicao: str = Field(pattern=r"^\d{4}-\d{2}-\d{2}$")
    patrimonio: str = Field(min_length=10)
    status: str = Field(min_length=10)

class EquipamentoPublico(BaseModel):      # SAI na resposta
    id: int
    nome: str
    descricao: str
    data_aquisicao: str
    patrimonio: str
    status: str

class EquipamentoAtualizar(BaseModel):    # ENTRA na edicao, tudo opcional
    nome: str | None = None
    descricao: str | None = None
    data_aquisicao: str | None = None
    patrimonio: str | None = None
    status: str | None = None
