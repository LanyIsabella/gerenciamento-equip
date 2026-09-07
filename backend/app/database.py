# arquivo de configuração do banco de dados, incluindo a criação da engine e da sessão (já usando o SQLAlchemy e o postgresql)

from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.config import settings


class Base(DeclarativeBase):
    pass

# administrador de conexões com o banco de dados
engine = create_engine(
    settings.database_url,
    pool_pre_ping=True,
)

# cria as sessões com o banco que serão utilizadas nas transações
SessionLocal = sessionmaker(
    bind=engine,
    class_=Session,
    autoflush=False,
    expire_on_commit=False,
)


def get_db() -> Generator[Session, None, None]:
    with SessionLocal() as session:
        yield session