from app.usuarios.service import gerar_hash_senha, verificar_senha


def test_senha_e_guardada_com_bcrypt_e_verificada_sem_expor_o_valor_original():
    senha_hash = gerar_hash_senha("senha123")

    assert senha_hash.startswith(("$2a$", "$2b$", "$2y$"))
    assert verificar_senha("senha123", senha_hash)
    assert not verificar_senha("senha-errada", senha_hash)
