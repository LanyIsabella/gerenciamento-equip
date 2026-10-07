from sqlalchemy import select
from sqlalchemy.orm import joinedload

from app.repository import RepositorioBase
from .models import Manutencao


class ManutencaoRepository(RepositorioBase):
    def _consulta_com_relacionamentos(self):
        return select(Manutencao).options(
            joinedload(Manutencao.equipamento),
            joinedload(Manutencao.responsavel),
        )

    def cadastrar(self, dados: dict) -> Manutencao:
        manutencao = Manutencao(**dados)
        self.session.add(manutencao)
        self._confirmar()
        self.session.refresh(manutencao)
        return self.buscar_por_id(manutencao.id)

    def listar(
        self,
        id_equipamento: int | None = None,
        tipo: str | None = None,
        status: str | None = None,
        id_responsavel: int | None = None,
    ) -> list[Manutencao]:
        consulta = self._consulta_com_relacionamentos().order_by(Manutencao.id)

        if id_equipamento is not None:
            consulta = consulta.where(Manutencao.id_equipamento == id_equipamento)

        if tipo:
            consulta = consulta.where(Manutencao.tipo == tipo)

        if status:
            consulta = consulta.where(Manutencao.status == status)

        if id_responsavel is not None:
            consulta = consulta.where(Manutencao.id_responsavel == id_responsavel)

        return list(self.session.scalars(consulta).all())

    def buscar_por_id(self, id_manutencao: int) -> Manutencao | None:
        return self.session.scalar(
            self._consulta_com_relacionamentos().where(Manutencao.id == id_manutencao)
        )

    def atualizar(self, manutencao: Manutencao, dados: dict) -> Manutencao:
        for campo, valor in dados.items():
            setattr(manutencao, campo, valor)
        self._confirmar()
        self.session.refresh(manutencao)
        return self.buscar_por_id(manutencao.id)

    def apagar(self, manutencao: Manutencao) -> None:
        self.session.delete(manutencao)
        self._confirmar()
