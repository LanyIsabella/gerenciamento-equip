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

  Future<dynamic> getAutenticado(
    String caminho,
    String token, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await client.get(
      _uri(caminho, queryParameters),
      headers: _headers(token),
    );
    return _jsonValue(response);
  }

  Future<dynamic> postAutenticado(
    String caminho,
    String token,
    Map<String, dynamic> dados,
  ) async {
    final response = await client.post(
      _uri(caminho),
      headers: _headers(token),
      body: jsonEncode(dados),
    );
    return _jsonValue(response);
  }

  Future<dynamic> patchAutenticado(
    String caminho,
    String token,
    Map<String, dynamic> dados,
  ) async {
    final response = await client.patch(
      _uri(caminho),
      headers: _headers(token),
      body: jsonEncode(dados),
    );
    return _jsonValue(response);
  }

  Future<void> deleteAutenticado(String caminho, String token) async {
    final response = await client.delete(
      _uri(caminho),
      headers: _headers(token),
    );
    _jsonValue(response);
  }

  Uri _uri(String caminho, [Map<String, String>? queryParameters]) {
    return Uri.parse('$baseUrl$caminho').replace(
      queryParameters: queryParameters == null || queryParameters.isEmpty
          ? null
          : queryParameters,
    );
  }

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Map<String, dynamic> _json(http.Response response) {
    return _jsonValue(response) as Map<String, dynamic>;
  }

  dynamic _jsonValue(http.Response response) {
    final body =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        body is Map<String, dynamic>
            ? _mensagemDeErro(body['detail'])
            : 'Não foi possível concluir a operação',
        response.statusCode,
      );
    }
    return body;
  }

  String _mensagemDeErro(dynamic detail) {
    if (detail is String && detail.isNotEmpty) return detail;

    if (detail is List) {
      return detail.map((item) {
        if (item is! Map) return item.toString();
        final mensagem = item['msg']?.toString() ?? 'Campo inválido';
        final local = item['loc'];
        if (local is List && local.isNotEmpty) {
          return '${local.last}: $mensagem';
        }
        return mensagem;
      }).join('\n');
    }

    return 'Não foi possível concluir a operação';
  }
}
