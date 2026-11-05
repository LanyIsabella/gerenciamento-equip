import '../models/equipamento.dart';

/// Traduz o contrato externo de equipamentos para o modelo interno do app.
///
/// Somente este adaptador conhece os nomes dos campos enviados pela API de
/// equipamentos. O restante do aplicativo trabalha com seus próprios nomes e
/// modelos.
// Código anterior, antes do Adapter:
//
// return (resposta as List)
//     .map((item) => Equipamento.fromJson(item as Map<String, dynamic>))
//     .toList();
//
// E, para criar ou atualizar:
//
// return api.postAutenticado('/equipamentos/', token, dados.toJson());
//
// O model e o Repository conheciam diretamente o JSON externo. Isso não era
// funcional para trocar o fornecedor ou alterar nomes de campos, pois a
// conversão ficava espalhada entre camadas e telas/Services poderiam depender
// do contrato da API.
class EquipamentoApiAdapter {
  const EquipamentoApiAdapter();

  Equipamento fromApi(Map<String, dynamic> data) {
    final categoria = data['categoria'] as Map<String, dynamic>;
    final responsavel = data['responsavel'] as Map<String, dynamic>;

    return Equipamento(
      id: data['id'] as int,
      nome: data['nome'] as String,
      descricao: data['descricao'] as String,
      dataAquisicao: data['data_aquisicao'] as String,
      patrimonio: data['patrimonio'] as String,
      status: data['status'] as String,
      categoria: CategoriaResumo(
        id: categoria['id'] as int,
        nome: categoria['nome'] as String,
      ),
      responsavel: UsuarioResumo(
        id: responsavel['id'] as int,
        nome: responsavel['nome'] as String,
        cargo: responsavel['cargo'] as String,
      ),
    );
  }

  List<Equipamento> listFromApi(dynamic data) {
    return (data as List)
        .map((item) => fromApi(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, String> toQuery({
    String? busca,
    int? idCategoria,
    String? status,
  }) {
    return {
      if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
      if (idCategoria != null) 'id_categoria': '$idCategoria',
      if (status != null && status.isNotEmpty) 'status': status,
    };
  }

  Map<String, dynamic> toApi(EquipamentoInput input) {
    return {
      'nome': input.nome,
      'descricao': input.descricao,
      'data_aquisicao': input.dataAquisicao,
      'patrimonio': input.patrimonio,
      'status': input.status,
      'id_categoria': input.idCategoria,
      if (input.idResponsavel != null) 'id_responsavel': input.idResponsavel,
    };
  }
}
