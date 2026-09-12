from pydantic import BaseModel, ConfigDict, field_validator


class CategoriaResumo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str

    @field_validator("nome")
    @classmethod
    def validar_nome(cls, valor: str) -> str:
        if len(valor) > 100:
            raise ValueError("nome deve ter no máximo 100 caracteres")
        return valor
