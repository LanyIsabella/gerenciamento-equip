from __future__ import annotations

import sys
from logging.config import fileConfig
from pathlib import Path

from alembic import context
from dotenv import load_dotenv
from sqlalchemy import engine_from_config, pool

# O Alembic pode ser executado a partir da raiz do projeto ou de backend/.
# Incluímos backend no caminho para que os imports app.* funcionem nos dois casos.
BACKEND_DIR = Path(__file__).resolve().parents[1]
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

# O .env do projeto fica na raiz do repositório. Carregá-lo explicitamente
# deixa o comando independente do diretório atual.
load_dotenv(Path(__file__).resolve().parents[2] / ".env")

from app.config import settings  # noqa: E402
from app.database import Base  # noqa: E402
from app.categoria import models as categoria_models  # noqa: F401, E402
from app.equipamentos import models as equipamentos_models  # noqa: F401, E402
from app.manutencoes import models as manutencoes_models  # noqa: F401, E402
from app.usuarios import models as usuarios_models  # noqa: F401, E402

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# A aplicação e o Alembic usam a mesma URL PostgreSQL definida no .env.
# O escape de '%' é necessário porque a URL passa pelo ConfigParser do Alembic.
config.set_main_option(
    "sqlalchemy.url",
    settings.database_url.replace("%", "%%"),
)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Gera o SQL das migrações sem abrir uma conexão com o banco."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Abre uma conexão PostgreSQL e executa as migrações."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
