import 'package:flutter_test/flutter_test.dart';

import 'package:equip_control_app/models/usuario.dart';
import 'package:equip_control_app/repositories/auth_repository.dart';
import 'package:equip_control_app/services/api_client.dart';
import 'package:equip_control_app/services/sessao_service.dart';

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
  test('login guarda sessão e avisa os ouvintes', () async {
    final service = SessaoService(FakeAuthRepository());
    var notificacoes = 0;
    service.addListener(() => notificacoes++);

    final entrou = await service.entrar('teste@exemplo.com', 'senha123');

    expect(entrou, isTrue);
    expect(service.token, 'token-fake');
    expect(service.usuario?.nome, 'Usuário Teste');
    expect(notificacoes, greaterThan(0));
  });

  test('senha errada permanece no login com mensagem de erro', () async {
    final repository = FakeAuthRepository()..senhaCorreta = false;
    final service = SessaoService(repository);

    final entrou = await service.entrar('teste@exemplo.com', 'errada');

    expect(entrou, isFalse);
    expect(service.erro, contains('inválidos'));
  });

  test('sair limpa a sessão e avisa os ouvintes', () async {
    final service = SessaoService(FakeAuthRepository());
    await service.entrar('teste@exemplo.com', 'senha123');
    var notificacoes = 0;
    service.addListener(() => notificacoes++);

    service.sair();

    expect(service.autenticada, isFalse);
    expect(service.token, isNull);
    expect(service.usuario, isNull);
    expect(notificacoes, 1);
  });
}
