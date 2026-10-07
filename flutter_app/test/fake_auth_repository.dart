import 'package:equip_control_app/models/usuario.dart';
import 'package:equip_control_app/repositories/auth_repository.dart';
import 'package:equip_control_app/services/api_client.dart';

class FakeAuthRepository implements AuthRepository {
  bool senhaCorreta = true;
  bool tokenValido = true;
  String? erroNoCadastro;
  int cadastrosRealizados = 0;

  @override
  Future<String> login(String email, String senha) async {
    if (!senhaCorreta) {
      throw const ApiException('E-mail ou senha inválidos', 401);
    }
    return 'token-fake';
  }

  @override
  Future<Usuario> buscarUsuarioAtual(String token) async {
    if (!tokenValido) {
      throw const ApiException('Token inválido', 401);
    }
    return const Usuario(
      id: 1,
      nome: 'Usuário Teste',
      email: 'teste@exemplo.com',
      cargo: 'visualizador',
      ativo: true,
    );
  }

  @override
  Future<void> cadastrarUsuario(String nome, String email, String senha) async {
    if (erroNoCadastro != null) {
      throw ApiException(erroNoCadastro!, 409);
    }
    cadastrosRealizados++;
  }
}
