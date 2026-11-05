import 'package:equip_control_app/adapters/equipamento_api_adapter.dart';
import 'package:equip_control_app/models/equipamento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const adapter = EquipamentoApiAdapter();

  test('traduz a resposta externa para o modelo interno', () {
    final equipamento = adapter.fromApi({
      'id': 1,
      'nome': 'Torno CNC',
      'descricao': 'Torno da produção',
      'data_aquisicao': '2024-01-10',
      'patrimonio': 'PAT-1',
      'status': 'Ativo',
      'categoria': {'id': 2, 'nome': 'Máquinas Pesadas'},
      'responsavel': {'id': 3, 'nome': 'Ana', 'cargo': 'Gestor'},
    });

    expect(equipamento.dataAquisicao, '2024-01-10');
    expect(equipamento.categoria.nome, 'Máquinas Pesadas');
    expect(equipamento.responsavel.cargo, 'Gestor');
  });

  test('traduz o modelo interno para o contrato externo de criação', () {
    const input = EquipamentoInput(
      nome: 'Furadeira',
      descricao: 'Ferramenta',
      dataAquisicao: '2025-02-03',
      patrimonio: 'PAT-3',
      status: 'Ativo',
      idCategoria: 2,
    );

    expect(adapter.toApi(input), {
      'nome': 'Furadeira',
      'descricao': 'Ferramenta',
      'data_aquisicao': '2025-02-03',
      'patrimonio': 'PAT-3',
      'status': 'Ativo',
      'id_categoria': 2,
    });
  });

  test('traduz os filtros internos para a consulta externa', () {
    expect(
      adapter.toQuery(busca: ' torno ', idCategoria: 2, status: 'Ativo'),
      {'busca': 'torno', 'id_categoria': '2', 'status': 'Ativo'},
    );
  });
}
