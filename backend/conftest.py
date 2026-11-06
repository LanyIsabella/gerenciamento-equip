"""Infraestrutura compartilhada para os testes de endpoint.

O módulo é carregado pelo pytest antes dos testes. Por isso as variáveis do
banco de teste são definidas antes de importar a aplicação e a engine.
"""

import os

os.environ["DATABASE_URL"] = "sqlite:///./backend/teste.db"
os.environ["AUTH_SECRET"] = "uma-chave-so-para-os-testes-com-mais-de-32-letras"

import pytest
from fastapi.testclient import TestClient

from app.database import Base, engine
from app.main import app


@pytest.fixture
def cliente():
    """Entrega um cliente da API com um schema limpo para cada teste."""

    Base.metadata.create_all(engine)
    try:
        with TestClient(app) as test_client:
            yield test_client
    finally:
        Base.metadata.drop_all(engine)

