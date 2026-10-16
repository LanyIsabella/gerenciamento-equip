"""insere as categorias iniciais do sistema

Revision ID: 20261015_01
Revises: 364dc22059f6
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "20261015_01"
down_revision: Union[str, Sequence[str], None] = "364dc22059f6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


CATEGORIAS = (
    (1, "Máquinas Pesadas", "Equipamentos de grande porte."),
    (2, "Ferramentas Elétricas", "Ferramentas acionadas por energia elétrica."),
    (3, "Equipamentos de TI", "Computadores, servidores e periféricos."),
    (4, "Veículos Industriais", "Veículos utilizados na operação."),
    (5, "Instrumentos de Medição", "Instrumentos usados para medições técnicas."),
)


def upgrade() -> None:
    categorias = sa.table(
        "categorias",
        sa.column("id", sa.Integer),
        sa.column("nome", sa.String),
        sa.column("descricao", sa.Text),
    )
    op.bulk_insert(
        categorias,
        [
            {"id": id_categoria, "nome": nome, "descricao": descricao}
            for id_categoria, nome, descricao in CATEGORIAS
        ],
    )

    # Os IDs são definidos para manter o contrato atual do formulário Flutter.
    op.execute(
        sa.text(
            "SELECT setval(pg_get_serial_sequence('categorias', 'id'), "
            "GREATEST((SELECT MAX(id) FROM categorias), 1), true)"
        )
    )


def downgrade() -> None:
    ids = tuple(id_categoria for id_categoria, _, _ in CATEGORIAS)
    op.execute(
        sa.text("DELETE FROM categorias WHERE id = ANY(:ids)").bindparams(
            sa.bindparam("ids", value=list(ids), type_=sa.ARRAY(sa.Integer))
        )
    )
