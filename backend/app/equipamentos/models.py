from datetime import date
from typing import TYPE_CHECKING

from sqlalchemy import Date, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


if TYPE_CHECKING:
    from app.categoria.models import Categoria
    from app.manutencoes.models import Manutencao
    from app.usuarios.models import Usuario


class Equipamento(Base):
    __tablename__ = "equipamentos"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    nome: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    descricao: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    data_aquisicao: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )

    patrimonio: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        unique=True,
        index=True,
    )

    status: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    id_categoria: Mapped[int] = mapped_column(
        ForeignKey("categorias.id"),
        nullable=False,
        index=True,
    )

    id_responsavel: Mapped[int] = mapped_column(
        ForeignKey("usuarios.id"),
        nullable=False,
        index=True,
    )

    categoria: Mapped["Categoria"] = relationship(
        back_populates="equipamentos",
    )

    responsavel: Mapped["Usuario"] = relationship(
        back_populates="equipamentos_responsaveis",
    )

    manutencoes: Mapped[list["Manutencao"]] = relationship(
        back_populates="equipamento",
    )
