import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:equip_control_app/services/api_client.dart';

void main() {
  test('converte e-mail repetido em mensagem de domínio', () async {
    final api = ApiClient(
      baseUrl: 'http://api',
      client: MockClient(
        (_) async => http.Response(
          '{"detail":"E-mail já cadastrado"}',
          409,
        ),
      ),
    );

    expect(
      () => api.cadastrarUsuario(
        nome: 'Usuário',
        email: 'repetido@exemplo.com',
        senha: 'senha123',
      ),
      throwsA(
        predicate<ApiException>(
          (erro) =>
              erro.message == 'E-mail já cadastrado' && erro.statusCode == 409,
        ),
      ),
    );
  });

  test('converte erros de validação em texto para a tela', () async {
    final api = ApiClient(
      baseUrl: 'http://api',
      client: MockClient(
        (_) async => http.Response(
          '{"detail":[{"loc":["body","senha"],"msg":"String should have at least 6 characters"}]}',
          422,
        ),
      ),
    );

    expect(
      () => api.cadastrarUsuario(
        nome: 'Usuário',
        email: 'novo@exemplo.com',
        senha: '123',
      ),
      throwsA(
        predicate<ApiException>(
          (erro) => erro.message.contains('senha:') && erro.statusCode == 422,
        ),
      ),
    );
  });
}
