from fastapi import APIRouter, HTTPException, status
from .schemas import EquipamentoCriar, EquipamentoPublico, EquipamentoAtualizar

router = APIRouter(prefix="/equipamentos", tags=["Equipamentos"])

# Banco de mentira: uma lista em memoria. Vira banco de verdade no encontro 4.
equipamentos: list[dict] = []


@router.get("/", response_model=list[EquipamentoPublico])
def listar():
    return equipamentos

@router.post("/", response_model=EquipamentoPublico, status_code=201)
def criar(dados: EquipamentoCriar):
    novo = {"id": len(equipamentos) + 1, **dados.model_dump()}
    equipamentos.append(novo)
    return novo

@router.get("/{id_equipamento}", response_model=EquipamentoPublico)
def buscar(id_equipamento: int):
    for p in equipamentos:
        if p["id"] == id_equipamento:
            return p
    raise HTTPException(status_code=404, detail="Equipamento não encontrado")

@router.patch("/{id_equipamento}", response_model=EquipamentoPublico)
def atualizar(id_equipamento: int, dados: EquipamentoAtualizar):
    for p in equipamentos:
        if p["id"] == id_equipamento:
            p.update(dados.model_dump(exclude_unset=True))
            return p
    raise HTTPException(status_code=404, detail="Equipamento não encontrado")

@router.delete("/{id_equipamento}", status_code=204)
def apagar(id_equipamento: int):
    for p in equipamentos:
        if p["id"] == id_equipamento:
            equipamentos.remove(p)
            return
    raise HTTPException(status_code=404, detail="Equipamento não encontrado")



