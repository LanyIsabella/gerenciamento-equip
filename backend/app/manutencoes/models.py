from datetime import date
from typing import TYPE_CHECKING

from sqlalchemy import Date, Float, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.equipamentos.models import Equipamento
    from app.usuarios.models import Usuario


class Manutencao(Base):
    __tablename__ = "manutencoes"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    id_equipamento: Mapped[int] = mapped_column(
        ForeignKey("equipamentos.id"),
        nullable=False,
        index=True,
    )

    id_responsavel: Mapped[int] = mapped_column(
        ForeignKey("usuarios.id"),
        nullable=False,
        index=True,
    )

    descricao: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    status: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    tipo: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )

    custo: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    data_abertura: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )

    data_conclusao: Mapped[date | None] = mapped_column(
        Date,
        nullable=True,
    )

    equipamento: Mapped["Equipamento"] = relationship(
        back_populates="manutencoes",
    )

    responsavel: Mapped["Usuario"] = relationship(
        back_populates="manutencoes_responsaveis",
    )
