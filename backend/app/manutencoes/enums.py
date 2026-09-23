from enum import Enum


class TipoManutencao(str, Enum):
    PREVENTIVA = "Preventiva"
    CORRETIVA = "Corretiva"
