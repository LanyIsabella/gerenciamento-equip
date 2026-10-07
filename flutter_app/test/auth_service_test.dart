import 'package:flutter_test/flutter_test.dart';

import 'package:equip_control_app/models/usuario.dart';
import 'package:equip_control_app/repositories/auth_repository.dart';
import 'package:equip_control_app/services/api_client.dart';
import 'package:equip_control_app/services/auth_service.dart';

class FakeAuthRepository implements AuthRepository {
  bool senhaCorreta = true;

  @override
  Future<String> login(String email, String senha) async {
    if (!senhaCorreta) {
      throw const ApiException('E-mail ou senha inválidos', 401);
    }
    return 'token-fake';
  }

  @override
  Future<Usuario> buscarUsuarioAtual(String token) async {
    return const Usuario(
      id: 1,
      nome: 'Usuário Teste',
      email: 'teste@exemplo.com',
      cargo: 'visualizador',
      ativo: true,
    );
  }

  @override
  Future<void> cadastrarUsuario(String nome, String email, String senha) async {}
}

void main() {
  test('login guarda token e busca o usuário atual', () async {
    final service = AuthService(FakeAuthRepository());

    final usuario = await service.login('teste@exemplo.com', 'senha123');

    expect(service.token, 'token-fake');
    expect(usuario.nome, 'Usuário Teste');
  });

  test('senha errada retorna erro da API falsa', () async {
    final repository = FakeAuthRepository()..senhaCorreta = false;
    final service = AuthService(repository);

    expect(
      () => service.login('teste@exemplo.com', 'errada'),
      throwsA(isA<ApiException>()),
    );
  });
}
