import 'package:flutter/foundation.dart';

import '../models/usuario.dart';
import '../repositories/auth_repository.dart';
import '../repositories/token_repository.dart';
import 'api_client.dart';

class SessaoService extends ChangeNotifier {
  final AuthRepository repository;
  final TokenRepository tokenRepository;

  String? _token;
  Usuario? _usuario;
  String? _erro;
  bool _carregando = false;

  SessaoService(
    this.repository, {
    TokenRepository? tokenRepository,
  }) : tokenRepository = tokenRepository ?? MemoriaTokenRepository();

  String? get token => _token;
  Usuario? get usuario => _usuario;
  String? get erro => _erro;
  bool get carregando => _carregando;
  bool get autenticada => _token != null && _usuario != null;

  Future<bool> entrar(String email, String senha) async {
    _iniciarCarregamento();
    try {
      final token = await repository.login(email, senha);
      final usuario = await repository.buscarUsuarioAtual(token);
      await tokenRepository.salvar(token);
      _token = token;
      _usuario = usuario;
      return true;
    } on ApiException catch (exception) {
      await _tratarErroApi(exception);
      return false;
    } catch (_) {
      _limparSessaoEmMemoria();
      _erro = 'Não foi possível conectar à API';
      return false;
    } finally {
      _finalizarCarregamento();
    }
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    _iniciarCarregamento();
    try {
      await repository.cadastrarUsuario(nome, email, senha);
      return await entrar(email, senha);
    } on ApiException catch (exception) {
      _erro = exception.message;
      return false;
    } catch (_) {
      _erro = 'Não foi possível conectar à API';
      return false;
    } finally {
      _finalizarCarregamento();
    }
  }

  Future<bool> restaurar() async {
    _iniciarCarregamento();
    try {
      final token = await tokenRepository.ler();
      if (token == null || token.isEmpty) return false;

      final usuario = await repository.buscarUsuarioAtual(token);
      _token = token;
      _usuario = usuario;
      return true;
    } on ApiException catch (exception) {
      if (exception.statusCode == 401) {
        await tokenRepository.apagar();
      }
      _limparSessaoEmMemoria();
      return false;
    } catch (_) {
      _limparSessaoEmMemoria();
      return false;
    } finally {
      _finalizarCarregamento();
    }
  }

  Future<void> sair() async {
    await tokenRepository.apagar();
    _limparSessaoEmMemoria();
    _erro = null;
    notifyListeners();
  }

  void _iniciarCarregamento() {
    _carregando = true;
    _erro = null;
    notifyListeners();
  }

  void _finalizarCarregamento() {
    _carregando = false;
    notifyListeners();
  }

  Future<void> _tratarErroApi(ApiException exception) async {
    if (exception.statusCode == 401) {
      await tokenRepository.apagar();
    }
    _limparSessaoEmMemoria();
    _erro = exception.message;
  }

  void _limparSessaoEmMemoria() {
    _token = null;
    _usuario = null;
  }
}
