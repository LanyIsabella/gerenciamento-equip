import '../models/usuario.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository repository;
  String? token;
  Usuario? usuario;

  AuthService(this.repository);

  Future<Usuario> login(String email, String senha) async {
    token = await repository.login(email, senha);
    usuario = await repository.buscarUsuarioAtual(token!);
    return usuario!;
  }

  Future<void> cadastrar(String nome, String email, String senha) {
    return repository.cadastrarUsuario(nome, email, senha);
  }
}
