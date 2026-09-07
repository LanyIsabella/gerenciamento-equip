from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from .models import Equipamento


class EquipamentoRepository:
    def __init__(self, session: Session):
        self.session = session

    def cadastrar(self, dados: dict) -> Equipamento:
        equipamento = Equipamento(**dados)

        try:
            self.session.add(equipamento)
            self.session.commit()
            self.session.refresh(equipamento)
        except Exception:
            self.session.rollback()
            raise

        return self.buscar_por_id(equipamento.id)

    def buscar_por_id(self, id_equipamento: int) -> Equipamento | None:
        consulta = (
            select(Equipamento)
            .options(
                joinedload(Equipamento.categoria),
                joinedload(Equipamento.responsavel),
            )
            .where(Equipamento.id == id_equipamento)
        )

        return self.session.scalar(consulta)

    def buscar_por_patrimonio(self, patrimonio: str) -> Equipamento | None:
        consulta = (
            select(Equipamento)
            .options(
                joinedload(Equipamento.categoria),
                joinedload(Equipamento.responsavel),
            )
            .where(Equipamento.patrimonio == patrimonio)
        )

        return self.session.scalar(consulta)

    def atualizar(self, equipamento: Equipamento, dados: dict) -> Equipamento:
        for campo, valor in dados.items():
            setattr(equipamento, campo, valor)
        try:
            self.session.commit()
            self.session.refresh(equipamento)
        except Exception:
            self.session.rollback()
            raise
        return self.buscar_por_id(equipamento.id)

    def apagar(self, equipamento: Equipamento) -> None:
        try:
            self.session.delete(equipamento)
            self.session.commit()
        except Exception:
            self.session.rollback()
            raise

    def listar(self) -> list[Equipamento]:
        consulta = (
            select(Equipamento)
            .options(
                joinedload(Equipamento.categoria),
                joinedload(Equipamento.responsavel),
            )
            .order_by(Equipamento.id)
        )

        equipamentos = self.session.scalars(consulta).all()

        return list(equipamentos)
