import '../models/manutencao.dart';
import '../services/api_client.dart';

abstract class ManutencoesRepository {
  Future<List<Manutencao>> listar({
    int? idEquipamento,
    String? tipo,
    String? status,
  });

  Future<Manutencao> criar(ManutencaoInput dados);
  Future<Manutencao> atualizar(int id, ManutencaoInput dados);
  Future<Manutencao> encerrar(int id, String dataConclusao);
  Future<void> excluir(int id);
}

class ApiManutencoesRepository implements ManutencoesRepository {
  final ApiClient api;
  final String? Function() tokenProvider;

  ApiManutencoesRepository(this.api, this.tokenProvider);

  String _token() {
    final token = tokenProvider();
    if (token == null || token.isEmpty) {
      throw const ApiException('Sessão expirada', 401);
    }
    return token;
  }

  @override
  Future<List<Manutencao>> listar({
    int? idEquipamento,
    String? tipo,
    String? status,
  }) async {
    final query = <String, String>{
      if (idEquipamento != null) 'id_equipamento': '$idEquipamento',
      if (tipo != null && tipo.isNotEmpty) 'tipo': tipo,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final resposta = await api.getAutenticado(
      '/manutencoes/',
      _token(),
      queryParameters: query,
    );
    return (resposta as List)
        .map((item) => Manutencao.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Manutencao> criar(ManutencaoInput dados) async {
    final resposta = await api.postAutenticado(
      '/manutencoes/',
      _token(),
      dados.toJson(),
    );
    return Manutencao.fromJson(resposta as Map<String, dynamic>);
  }

  @override
  Future<Manutencao> atualizar(int id, ManutencaoInput dados) async {
    final resposta = await api.patchAutenticado(
      '/manutencoes/$id',
      _token(),
      dados.toJson(),
    );
    return Manutencao.fromJson(resposta as Map<String, dynamic>);
  }

  @override
  Future<Manutencao> encerrar(int id, String dataConclusao) async {
    final resposta = await api.patchAutenticado(
      '/manutencoes/$id/encerrar',
      _token(),
      {'data_conclusao': dataConclusao},
    );
    return Manutencao.fromJson(resposta as Map<String, dynamic>);
  }

  @override
  Future<void> excluir(int id) {
    return api.deleteAutenticado('/manutencoes/$id', _token());
  }
}
