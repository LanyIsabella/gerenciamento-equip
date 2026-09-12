from typing import TYPE_CHECKING

from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


if TYPE_CHECKING:
    from app.equipamentos.models import Equipamento


class Categoria(Base):
    __tablename__ = "categorias"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    nome: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        unique=True,
        index=True,
    )

    descricao: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    equipamentos: Mapped[list["Equipamento"]] = relationship(
        back_populates="categoria",
    )
