from sqlalchemy import Boolean, Enum as SqlEnum, String
from typing import TYPE_CHECKING

from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base
from app.usuarios.enums import CargoUsuario
if TYPE_CHECKING:
    from app.equipamentos.models import Equipamento
    from app.manutencoes.models import Manutencao


class Usuario(Base):
    __tablename__ = "usuarios"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        autoincrement=True,
    )

    nome: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    email: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        unique=True,
        index=True,
    )

    senha_hash: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )

    cargo: Mapped[CargoUsuario] = mapped_column(
        SqlEnum(
            CargoUsuario,
            name="cargo_usuario",
            values_callable=lambda enum: [item.value for item in enum],
        ),
        nullable=False,
        default=CargoUsuario.VISUALIZADOR,
    )

    ativo: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )

    equipamentos_responsaveis: Mapped[list["Equipamento"]] = relationship(
        back_populates="responsavel",
    )

    manutencoes_responsaveis: Mapped[list["Manutencao"]] = relationship(
        back_populates="responsavel",
    )
