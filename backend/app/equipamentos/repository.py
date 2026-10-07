from sqlalchemy import or_, select
from sqlalchemy.orm import joinedload

from app.repository import RepositorioBase
from .models import Equipamento


class EquipamentoRepository(RepositorioBase):
    def cadastrar(self, dados: dict) -> Equipamento:
        equipamento = Equipamento(**dados)

        self.session.add(equipamento)
        self._confirmar()
        self.session.refresh(equipamento)

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
        self._confirmar()
        self.session.refresh(equipamento)
        return self.buscar_por_id(equipamento.id)

    def apagar(self, equipamento: Equipamento) -> None:
        self.session.delete(equipamento)
        self._confirmar()

    def listar(
        self,
        busca: str | None = None,
        id_categoria: int | None = None,
        status: str | None = None,
        id_responsavel: int | None = None,
    ) -> list[Equipamento]:
        consulta = (
            select(Equipamento)
            .options(
                joinedload(Equipamento.categoria),
                joinedload(Equipamento.responsavel),
            )
            .order_by(Equipamento.id)
        )

        if busca:
            termo = f"%{busca.strip()}%"
            consulta = consulta.where(
                or_(
                    Equipamento.nome.ilike(termo),
                    Equipamento.patrimonio.ilike(termo),
                )
            )

        if id_categoria is not None:
            consulta = consulta.where(Equipamento.id_categoria == id_categoria)

        if status:
            consulta = consulta.where(Equipamento.status == status)

        if id_responsavel is not None:
            consulta = consulta.where(Equipamento.id_responsavel == id_responsavel)

        equipamentos = self.session.scalars(consulta).all()

        return list(equipamentos)
