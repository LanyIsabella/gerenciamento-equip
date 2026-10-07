import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenRepository {
  Future<String?> ler();
  Future<void> salvar(String token);
  Future<void> apagar();
}

class SharedPreferencesTokenRepository implements TokenRepository {
  static const _chaveToken = 'auth_token';

  final SharedPreferences preferences;

  SharedPreferencesTokenRepository(this.preferences);

  @override
  Future<String?> ler() async => preferences.getString(_chaveToken);

  @override
  Future<void> salvar(String token) async {
    await preferences.setString(_chaveToken, token);
  }

  @override
  Future<void> apagar() async {
    await preferences.remove(_chaveToken);
  }
}

class MemoriaTokenRepository implements TokenRepository {
  String? _token;

  @override
  Future<String?> ler() async => _token;

  @override
  Future<void> salvar(String token) async {
    _token = token;
  }

  @override
  Future<void> apagar() async {
    _token = null;
  }
}
