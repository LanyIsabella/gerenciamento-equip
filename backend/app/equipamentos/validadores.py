def normalizar_patrimonio(patrimonio: str) -> str:
    valor = patrimonio.strip().upper()
    while valor.startswith("PAT-PAT-"):
        valor = valor[4:]
    return valor if valor.startswith("PAT-") else f"PAT-{valor}"
