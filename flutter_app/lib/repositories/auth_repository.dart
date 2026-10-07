import '../models/usuario.dart';
import '../services/api_client.dart';

abstract class AuthRepository {
  Future<String> login(String email, String senha);
  Future<Usuario> buscarUsuarioAtual(String token);
  Future<void> cadastrarUsuario(String nome, String email, String senha);
}

class ApiAuthRepository implements AuthRepository {
  final ApiClient api;

  ApiAuthRepository(this.api);

  @override
  Future<String> login(String email, String senha) async {
    final data = await api.login(email, senha);
    return data['access_token'] as String;
  }

  @override
  Future<Usuario> buscarUsuarioAtual(String token) async {
    return Usuario.fromJson(await api.buscarUsuarioAtual(token));
  }

  @override
  Future<void> cadastrarUsuario(String nome, String email, String senha) {
    return api.cadastrarUsuario(nome: nome, email: email, senha: senha);
  }
}
