from pydantic import BaseModel, ConfigDict

from .enums import CargoUsuario


class UsuarioResumo(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    nome: str
    cargo: CargoUsuario