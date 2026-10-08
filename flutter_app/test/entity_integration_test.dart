import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:equip_control_app/models/equipamento.dart';
import 'package:equip_control_app/repositories/equipamentos_repository.dart';
import 'package:equip_control_app/repositories/manutencoes_repository.dart';
import 'package:equip_control_app/services/api_client.dart';

void main() {
  test('lista equipamentos com token e filtros da tela', () async {
    late http.Request request;
    final api = ApiClient(
      baseUrl: 'http://api',
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response(
          '''
          [{
            "id": 1,
            "nome": "Torno CNC",
            "descricao": "Torno da produção",
            "data_aquisicao": "2024-01-10",
            "patrimonio": "PAT-1",
            "status": "Ativo",
            "categoria": {"id": 1, "nome": "Máquinas Pesadas"},
            "responsavel": {"id": 2, "nome": "Ana", "cargo": "Gestor"}
          }]
          ''',
          200,
        );
      }),
    );

    final repository = ApiEquipamentosRepository(api, () => 'token');
    final equipamentos = await repository.listar(
      busca: 'torno',
      idCategoria: 1,
      status: 'Ativo',
    );

    expect(request.method, 'GET');
    expect(request.headers['authorization'], 'Bearer token');
    expect(request.url.queryParameters['busca'], 'torno');
    expect(request.url.queryParameters['id_categoria'], '1');
    expect(request.url.queryParameters['status'], 'Ativo');
    expect(equipamentos.single.nome, 'Torno CNC');
    expect(equipamentos.single.categoria.nome, 'Máquinas Pesadas');
  });

  test('cria equipamento com o contrato da API', () async {
    late http.Request request;
    final api = ApiClient(
      baseUrl: 'http://api',
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response(
          '''
          {
            "id": 3,
            "nome": "Furadeira",
            "descricao": "Ferramenta",
            "data_aquisicao": "2025-02-03",
            "patrimonio": "PAT-3",
            "status": "Ativo",
            "categoria": {"id": 2, "nome": "Ferramentas"},
            "responsavel": {"id": 7, "nome": "Usuário", "cargo": "Gestor"}
          }
          ''',
          201,
        );
      }),
    );

    final repository = ApiEquipamentosRepository(api, () => 'token');
    final equipamento = await repository.criar(
      const EquipamentoInput(
        nome: 'Furadeira',
        descricao: 'Ferramenta',
        dataAquisicao: '2025-02-03',
        patrimonio: 'PAT-3',
        status: 'Ativo',
        idCategoria: 2,
      ),
    );

    expect(request.method, 'POST');
    expect(request.headers['authorization'], 'Bearer token');
    expect(request.body, contains('"id_categoria":2'));
    expect(equipamento.id, 3);
  });

  test('lista manutenções e envia filtros autenticados', () async {
    late http.Request request;
    final api = ApiClient(
      baseUrl: 'http://api',
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response(
          '''
          [{
            "id": 4,
            "id_equipamento": 1,
            "equipamento": {"id": 1, "nome": "Torno CNC", "patrimonio": "PAT-1"},
            "id_responsavel": 2,
            "responsavel": {"id": 2, "nome": "Ana", "cargo": "Técnico"},
            "descricao": "Troca de óleo",
            "status": "Pendente",
            "tipo": "Preventiva",
            "custo": 250.5,
            "data_abertura": "2025-04-01",
            "data_conclusao": null
          }]
          ''',
          200,
        );
      }),
    );

    final repository = ApiManutencoesRepository(api, () => 'token');
    final manutencoes = await repository.listar(
      idEquipamento: 1,
      tipo: 'Preventiva',
      status: 'Pendente',
    );

    expect(request.url.path, '/manutencoes/');
    expect(request.headers['authorization'], 'Bearer token');
    expect(request.url.queryParameters['id_equipamento'], '1');
    expect(request.url.queryParameters['tipo'], 'Preventiva');
    expect(request.url.queryParameters['status'], 'Pendente');
    expect(manutencoes.single.custo, 250.5);
  });

  test('encerra manutenção pelo endpoint específico', () async {
    late http.Request request;
    final api = ApiClient(
      baseUrl: 'http://api',
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response(
          '''
          {
            "id": 4,
            "id_equipamento": 1,
            "equipamento": {"id": 1, "nome": "Torno CNC", "patrimonio": "PAT-1"},
            "id_responsavel": 2,
            "responsavel": {"id": 2, "nome": "Ana", "cargo": "Técnico"},
            "descricao": "Troca de óleo",
            "status": "Concluída",
            "tipo": "Preventiva",
            "custo": 250.5,
            "data_abertura": "2025-04-01",
            "data_conclusao": "2025-04-03"
          }
          ''',
          200,
        );
      }),
    );

    final repository = ApiManutencoesRepository(api, () => 'token');
    final manutencao = await repository.encerrar(4, '2025-04-03');

    expect(request.method, 'PATCH');
    expect(request.url.path, '/manutencoes/4/encerrar');
    expect(request.body, '{"data_conclusao":"2025-04-03"}');
    expect(manutencao.status, 'Concluída');
  });
}
