import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import '../repositories/auth_repository.dart';
import 'api_client.dart';

class SessaoService extends ChangeNotifier {
  final AuthRepository repository;

  String? _token;
  Usuario? _usuario;
  String? _erro;
  bool _carregando = false;

  SessaoService(this.repository);

  String? get token => _token;
  Usuario? get usuario => _usuario;
  String? get erro => _erro;
  bool get carregando => _carregando;
  bool get autenticada => _token != null && _usuario != null;

  Future<bool> entrar(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final token = await repository.login(email, senha);
      final usuario = await repository.buscarUsuarioAtual(token);
      _token = token;
      _usuario = usuario;
      return true;
    } on ApiException catch (exception) {
      _token = null;
      _usuario = null;
      _erro = exception.message;
      return false;
    } catch (_) {
      _token = null;
      _usuario = null;
      _erro = 'Não foi possível conectar à API';
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      await repository.cadastrarUsuario(nome, email, senha);
      return true;
    } on ApiException catch (exception) {
      _erro = exception.message;
      return false;
    } catch (_) {
      _erro = 'Não foi possível conectar à API';
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void sair() {
    _token = null;
    _usuario = null;
    _erro = null;
    notifyListeners();
  }
}
