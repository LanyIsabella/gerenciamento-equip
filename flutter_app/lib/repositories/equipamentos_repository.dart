import '../models/equipamento.dart';
import '../services/api_client.dart';

abstract class EquipamentosRepository {
  Future<List<Equipamento>> listar({
    String? busca,
    int? idCategoria,
    String? status,
  });

  Future<Equipamento> criar(EquipamentoInput dados);
  Future<Equipamento> atualizar(int id, EquipamentoInput dados);
  Future<void> excluir(int id);
}

class ApiEquipamentosRepository implements EquipamentosRepository {
  final ApiClient api;
  final String? Function() tokenProvider;

  ApiEquipamentosRepository(this.api, this.tokenProvider);

  String _token() {
    final token = tokenProvider();
    if (token == null || token.isEmpty) {
      throw const ApiException('Sessão expirada', 401);
    }
    return token;
  }

  @override
  Future<List<Equipamento>> listar({
    String? busca,
    int? idCategoria,
    String? status,
  }) async {
    final query = <String, String>{
      if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
      if (idCategoria != null) 'id_categoria': '$idCategoria',
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final resposta = await api.getAutenticado(
      '/equipamentos/',
      _token(),
      queryParameters: query,
    );
    return (resposta as List)
        .map((item) => Equipamento.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Equipamento> criar(EquipamentoInput dados) async {
    final resposta = await api.postAutenticado(
      '/equipamentos/',
      _token(),
      dados.toJson(),
    );
    return Equipamento.fromJson(resposta as Map<String, dynamic>);
  }

  @override
  Future<Equipamento> atualizar(int id, EquipamentoInput dados) async {
    final resposta = await api.patchAutenticado(
      '/equipamentos/$id',
      _token(),
      dados.toJson(),
    );
    return Equipamento.fromJson(resposta as Map<String, dynamic>);
  }

  @override
  Future<void> excluir(int id) {
    return api.deleteAutenticado('/equipamentos/$id', _token());
  }
}
