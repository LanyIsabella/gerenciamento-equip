import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;
  final http.Client client;

  ApiClient({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await client.post(
      Uri.parse('$baseUrl/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    return _json(response);
  }

  Future<Map<String, dynamic>> buscarUsuarioAtual(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/usuarios/eu'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _json(response);
  }

  Future<void> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/usuarios/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
        'cargo': 'visualizador',
      }),
    );
    _json(response);
  }

  Map<String, dynamic> _json(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = body['detail'] ?? 'Não foi possível concluir a operação';
      throw ApiException(detail.toString(), response.statusCode);
    }
    return body;
  }
}
