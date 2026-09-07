from enum import Enum


class CargoUsuario(str, Enum):
    ADMINISTRADOR = "administrador"
    GERENTE = "gerente"
    TECNICO = "tecnico"
    VISUALIZADOR = "visualizador"