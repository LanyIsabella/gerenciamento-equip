from pydantic import BaseModel, ConfigDict


class CategoriaResumo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str