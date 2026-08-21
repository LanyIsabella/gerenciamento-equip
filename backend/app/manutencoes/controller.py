from fastapi import APIRouter, HTTPException, status
from .schemas import ManutencaoCriar, ManutencaoPublico, ManutencaoAtualizar

router = APIRouter(prefix="/manutencoes", tags=["Manutenções"])

# Banco de mentira: uma lista em memoria. Vira banco de verdade no encontro 4.
manutencoes: list[dict] = []


@router.get("/", response_model=list[ManutencaoPublico])
def listar():
    return manutencoes

@router.post("/", response_model=ManutencaoPublico, status_code=201)
def criar(dados: ManutencaoCriar):
    novo = {"id": len(manutencoes) + 1, **dados.model_dump()}
    manutencoes.append(novo)
    return novo

@router.get("/{id_manutencao}", response_model=ManutencaoPublico)
def buscar(id_manutencao: int):
    for p in manutencoes:
        if p["id"] == id_manutencao:
            return p
    raise HTTPException(status_code=404, detail="Manutenção não encontrada")

@router.patch("/{id_manutencao}", response_model=ManutencaoPublico)
def atualizar(id_manutencao: int, dados: ManutencaoAtualizar):
    for p in manutencoes:
        if p["id"] == id_manutencao:
            p.update(dados.model_dump(exclude_unset=True))
            return p
    raise HTTPException(status_code=404, detail="Manutenção não encontrada")

@router.delete("/{id_manutencao}", status_code=204)
def apagar(id_manutencao: int):
    for p in manutencoes:
        if p["id"] == id_manutencao:
            manutencoes.remove(p)
            return
    raise HTTPException(status_code=404, detail="Manutenção não encontrada")



