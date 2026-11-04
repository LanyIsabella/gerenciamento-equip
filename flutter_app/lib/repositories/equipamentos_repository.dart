import '../adapters/equipamento_api_adapter.dart';
import '../models/equipamento.dart';
import '../services/api_client.dart';

abstract class EquipamentosRepository {
  Future<List<Equipamento>> listar({
    String? busca,
    int? idCategoria,
    String? status,
  });

  Future<Equipamento> criar(EquipamentoInput dados);
  Future<Equipamento> buscarPorId(int id);
  Future<Equipamento> atualizar(int id, EquipamentoInput dados);
  Future<void> excluir(int id);
}

class ApiEquipamentosRepository implements EquipamentosRepository {
  final ApiClient api;
  final String? Function() tokenProvider;
  final EquipamentoApiAdapter adapter;

  ApiEquipamentosRepository(
    this.api,
    this.tokenProvider, {
    EquipamentoApiAdapter? adapter,
  }) : adapter = adapter ?? const EquipamentoApiAdapter();

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
    final query = adapter.toQuery(
      busca: busca,
      idCategoria: idCategoria,
      status: status,
    );
    final resposta = await api.getAutenticado(
      '/equipamentos/',
      _token(),
      queryParameters: query,
    );
    return adapter.listFromApi(resposta);
  }

  @override
  Future<Equipamento> criar(EquipamentoInput dados) async {
    final resposta = await api.postAutenticado(
      '/equipamentos/',
      _token(),
      adapter.toApi(dados),
    );
    return adapter.fromApi(resposta as Map<String, dynamic>);
  }

  @override
  Future<Equipamento> buscarPorId(int id) async {
    final resposta = await api.getAutenticado('/equipamentos/$id', _token());
    return adapter.fromApi(resposta as Map<String, dynamic>);
  }

  @override
  Future<Equipamento> atualizar(int id, EquipamentoInput dados) async {
    final resposta = await api.patchAutenticado(
      '/equipamentos/$id',
      _token(),
      adapter.toApi(dados),
    );
    return adapter.fromApi(resposta as Map<String, dynamic>);
  }

  @override
  Future<void> excluir(int id) {
    return api.deleteAutenticado('/equipamentos/$id', _token());
  }
}
