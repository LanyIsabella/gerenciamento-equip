"""Testes de endpoint do fluxo real de equipamentos.

Cada teste atravessa controller, service e repository usando somente o banco
isolado criado pela fixture `cliente`.
"""

from datetime import date

from app.categoria.models import Categoria
from app.database import SessionLocal


def criar_categoria() -> int:
    session = SessionLocal()
    try:
        categoria = Categoria(
            nome="Equipamentos de teste",
            descricao="Categoria criada somente durante o teste",
        )
        session.add(categoria)
        session.commit()
        session.refresh(categoria)
        return categoria.id
    finally:
        session.close()


def cadastrar_usuario_e_obter_token(cliente, email: str) -> dict[str, str]:
    resposta_cadastro = cliente.post(
        "/usuarios/",
        json={
            "nome": "Usuário de teste",
            "email": email,
            "senha": "senha123",
            "cargo": "gerente",
        },
    )
    assert resposta_cadastro.status_code == 201

    resposta_login = cliente.post(
        "/usuarios/login",
        json={"email": email, "senha": "senha123"},
    )
    assert resposta_login.status_code == 200
    return {"Authorization": f"Bearer {resposta_login.json()['access_token']}"}


def equipamento_payload(categoria_id: int, patrimonio: str = "PAT-0001") -> dict:
    return {
        "nome": "Torno CNC",
        "descricao": "Equipamento de produção",
        "data_aquisicao": date(2025, 1, 1).isoformat(),
        "patrimonio": patrimonio,
        "status": "Ativo",
        "id_categoria": categoria_id,
    }


def criar_equipamento(cliente, headers, categoria_id, patrimonio="PAT-0001"):
    resposta = cliente.post(
        "/equipamentos/",
        json=equipamento_payload(categoria_id, patrimonio),
        headers=headers,
    )
    assert resposta.status_code == 201
    return resposta.json()


def test_criar_equipamento_devolve_201_com_os_dados(cliente):
    headers = cadastrar_usuario_e_obter_token(cliente, "ana@ifg.edu.br")
    categoria_id = criar_categoria()

    resposta = cliente.post(
        "/equipamentos/",
        json=equipamento_payload(categoria_id),
        headers=headers,
    )

    assert resposta.status_code == 201
    assert resposta.json()["nome"] == "Torno CNC"
    assert resposta.json()["responsavel"]["nome"] == "Usuário de teste"


def test_sem_token_a_api_recusa_listagem(cliente):
    resposta = cliente.get("/equipamentos/")

    assert resposta.status_code == 401


def test_um_usuario_nao_ve_o_equipamento_de_outro(cliente):
    ana = cadastrar_usuario_e_obter_token(cliente, "ana@ifg.edu.br")
    bruno = cadastrar_usuario_e_obter_token(cliente, "bruno@ifg.edu.br")
    categoria_id = criar_categoria()
    criar_equipamento(cliente, ana, categoria_id)

    lista_da_ana = cliente.get("/equipamentos/", headers=ana)
    lista_do_bruno = cliente.get("/equipamentos/", headers=bruno)

    assert len(lista_da_ana.json()) == 1
    assert lista_do_bruno.json() == []


def test_editar_equipamento_devolve_o_nome_atualizado(cliente):
    headers = cadastrar_usuario_e_obter_token(cliente, "ana@ifg.edu.br")
    categoria_id = criar_categoria()
    equipamento = criar_equipamento(cliente, headers, categoria_id)

    resposta = cliente.patch(
        f"/equipamentos/{equipamento['id']}",
        json={"nome": "Torno CNC atualizado"},
        headers=headers,
    )

    assert resposta.status_code == 200
    assert resposta.json()["nome"] == "Torno CNC atualizado"


def test_excluir_equipamento_remove_o_item_da_lista(cliente):
    headers = cadastrar_usuario_e_obter_token(cliente, "ana@ifg.edu.br")
    categoria_id = criar_categoria()
    equipamento = criar_equipamento(cliente, headers, categoria_id)

    resposta = cliente.delete(
        f"/equipamentos/{equipamento['id']}",
        headers=headers,
    )
    lista = cliente.get("/equipamentos/", headers=headers)

    assert resposta.status_code == 204
    assert lista.json() == []


def test_equipamento_inexistente_devolve_404(cliente):
    headers = cadastrar_usuario_e_obter_token(cliente, "ana@ifg.edu.br")

    resposta = cliente.get("/equipamentos/999", headers=headers)

    assert resposta.status_code == 404


def test_patrimonio_repetido_devolve_409(cliente):
    headers = cadastrar_usuario_e_obter_token(cliente, "ana@ifg.edu.br")
    categoria_id = criar_categoria()
    criar_equipamento(cliente, headers, categoria_id)

    resposta = cliente.post(
        "/equipamentos/",
        json=equipamento_payload(categoria_id),
        headers=headers,
    )

    assert resposta.status_code == 409


def test_busca_devolve_so_o_equipamento_compatível(cliente):
    headers = cadastrar_usuario_e_obter_token(cliente, "ana@ifg.edu.br")
    categoria_id = criar_categoria()
    criar_equipamento(cliente, headers, categoria_id, "PAT-CNC")
    cliente.post(
        "/equipamentos/",
        json=equipamento_payload(categoria_id, "PAT-SERRA")
        | {"nome": "Serra Industrial"},
        headers=headers,
    )

    resposta = cliente.get(
        "/equipamentos/",
        params={"busca": "CNC"},
        headers=headers,
    )

    assert resposta.status_code == 200
    assert len(resposta.json()) == 1
    assert resposta.json()[0]["nome"] == "Torno CNC"


def test_senha_errada_devolve_401(cliente):
    cadastrar_usuario_e_obter_token(cliente, "ana@ifg.edu.br")

    resposta = cliente.post(
        "/usuarios/login",
        json={"email": "ana@ifg.edu.br", "senha": "senha-errada"},
    )

    assert resposta.status_code == 401

