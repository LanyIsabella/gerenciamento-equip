import 'package:equip_control_app/models/usuario.dart';
import 'package:equip_control_app/repositories/auth_repository.dart';
import 'package:equip_control_app/services/api_client.dart';

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
