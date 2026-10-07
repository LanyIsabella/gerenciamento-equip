from enum import Enum


def validar_tamanho_maximo(valor, campo: str, limite: int):
    if valor is None:
        return valor

    texto = valor.value if isinstance(valor, Enum) else valor
    if len(texto) > limite:
        raise ValueError(f"{campo} deve ter no máximo {limite} caracteres")
    return valor
