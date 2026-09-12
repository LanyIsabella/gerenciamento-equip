from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from .models import Manutencao


class ManutencaoRepository:
    def __init__(self, session: Session):
        self.session = session

    def _consulta_com_relacionamentos(self):
        return select(Manutencao).options(
            joinedload(Manutencao.equipamento),
            joinedload(Manutencao.responsavel),
        )

    def cadastrar(self, dados: dict) -> Manutencao:
        manutencao = Manutencao(**dados)
        try:
            self.session.add(manutencao)
            self.session.commit()
            self.session.refresh(manutencao)
        except Exception:
            self.session.rollback()
            raise
        return self.buscar_por_id(manutencao.id)

    def listar(
        self,
        id_equipamento: int | None = None,
        tipo: str | None = None,
        status: str | None = None,
    ) -> list[Manutencao]:
        consulta = self._consulta_com_relacionamentos().order_by(Manutencao.id)

        if id_equipamento is not None:
            consulta = consulta.where(Manutencao.id_equipamento == id_equipamento)

        if tipo:
            consulta = consulta.where(Manutencao.tipo == tipo)

        if status:
            consulta = consulta.where(Manutencao.status == status)

        return list(self.session.scalars(consulta).all())

    def buscar_por_id(self, id_manutencao: int) -> Manutencao | None:
        return self.session.scalar(
            self._consulta_com_relacionamentos().where(Manutencao.id == id_manutencao)
        )

    def atualizar(self, manutencao: Manutencao, dados: dict) -> Manutencao:
        for campo, valor in dados.items():
            setattr(manutencao, campo, valor)
        try:
            self.session.commit()
            self.session.refresh(manutencao)
        except Exception:
            self.session.rollback()
            raise
        return self.buscar_por_id(manutencao.id)

    def apagar(self, manutencao: Manutencao) -> None:
        try:
            self.session.delete(manutencao)
            self.session.commit()
        except Exception:
            self.session.rollback()
            raise
