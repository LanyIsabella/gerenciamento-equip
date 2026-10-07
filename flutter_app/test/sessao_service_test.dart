import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:equip_control_app/repositories/token_repository.dart';
import 'package:equip_control_app/services/sessao_service.dart';

import 'fake_auth_repository.dart';

void main() {
  test('login guarda sessão, token e avisa os ouvintes', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final service = SessaoService(
      FakeAuthRepository(),
      tokenRepository: SharedPreferencesTokenRepository(preferences),
    );
    var notificacoes = 0;
    service.addListener(() => notificacoes++);

    final entrou = await service.entrar('teste@exemplo.com', 'senha123');

    expect(entrou, isTrue);
    expect(service.token, 'token-fake');
    expect(preferences.getString('auth_token'), 'token-fake');
    expect(service.usuario?.nome, 'Usuário Teste');
    expect(notificacoes, greaterThan(0));
  });

  test('cadastro usa a API e entra automaticamente com a conta nova', () async {
    final repository = FakeAuthRepository();
    final service = SessaoService(repository);

    final entrou = await service.cadastrar(
      'Novo Usuário',
      'novo@exemplo.com',
      'senha123',
    );

    expect(entrou, isTrue);
    expect(repository.cadastrosRealizados, 1);
    expect(service.autenticada, isTrue);
  });

  test('senha errada mantém a mensagem de erro da API', () async {
    final repository = FakeAuthRepository()..senhaCorreta = false;
    final service = SessaoService(repository);

    final entrou = await service.entrar('teste@exemplo.com', 'errada');

    expect(entrou, isFalse);
    expect(service.erro, contains('inválidos'));
  });

  test('restaura sessão salva no dispositivo', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'token-fake'});
    final preferences = await SharedPreferences.getInstance();
    final service = SessaoService(
      FakeAuthRepository(),
      tokenRepository: SharedPreferencesTokenRepository(preferences),
    );

    final restaurada = await service.restaurar();

    expect(restaurada, isTrue);
    expect(service.autenticada, isTrue);
    expect(service.usuario?.email, 'teste@exemplo.com');
  });

  test('token rejeitado pela API é apagado', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'token-expirado'});
    final preferences = await SharedPreferences.getInstance();
    final repository = FakeAuthRepository()..tokenValido = false;
    final service = SessaoService(
      repository,
      tokenRepository: SharedPreferencesTokenRepository(preferences),
    );

    final restaurada = await service.restaurar();

    expect(restaurada, isFalse);
    expect(service.autenticada, isFalse);
    expect(preferences.getString('auth_token'), isNull);
  });

  test('sair limpa a sessão e o token persistido', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'token-fake'});
    final preferences = await SharedPreferences.getInstance();
    final service = SessaoService(
      FakeAuthRepository(),
      tokenRepository: SharedPreferencesTokenRepository(preferences),
    );
    await service.restaurar();

    var notificacoes = 0;
    service.addListener(() => notificacoes++);
    await service.sair();

    expect(service.autenticada, isFalse);
    expect(preferences.getString('auth_token'), isNull);
    expect(notificacoes, 1);
  });
}
