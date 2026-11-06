import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:equip_control_app/repositories/equipamentos_repository.dart';
import 'package:equip_control_app/screens/equipamentos_screen.dart';
import 'package:equip_control_app/services/api_client.dart';
import 'package:equip_control_app/services/equipamentos_service.dart';
import 'package:equip_control_app/services/sessao_service.dart';

import 'fake_auth_repository.dart';

class RespostaEquipamentosClient extends http.BaseClient {
  final String resposta;

  RespostaEquipamentosClient(this.resposta);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    expect(request.headers['Authorization'], 'Bearer token-fake');
    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(resposta)),
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

Future<Widget> telaDeEquipamentos(String resposta) async {
  final sessao = SessaoService(FakeAuthRepository());
  await sessao.entrar('teste@exemplo.com', 'senha123');
  final api = ApiClient(
    baseUrl: 'http://teste.local',
    client: RespostaEquipamentosClient(resposta),
  );
  final repository = ApiEquipamentosRepository(api, () => sessao.token);
  final service = EquipamentosService(repository, sessao);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: sessao),
      ChangeNotifierProvider.value(value: service),
    ],
    child: const MaterialApp(home: EquipamentosScreen()),
  );
}

void main() {
  testWidgets('a tela mostra o equipamento devolvido pela API falsa',
      (tester) async {
    await tester.pumpWidget(await telaDeEquipamentos('''[
      {
        "id": 1,
        "nome": "Torno CNC",
        "descricao": "Equipamento de produção",
        "data_aquisicao": "2025-01-01",
        "patrimonio": "PAT-1",
        "status": "Ativo",
        "categoria": {"id": 1, "nome": "Máquinas Pesadas"},
        "responsavel": {"id": 1, "nome": "Ana", "cargo": "gerente"}
      }
    ]'''));
    await tester.pumpAndSettle();

    expect(find.text('Torno CNC'), findsOneWidget);
    expect(find.textContaining('PAT-1'), findsOneWidget);
  });

  testWidgets('a tela informa quando a API falsa não devolve equipamentos',
      (tester) async {
    await tester.pumpWidget(await telaDeEquipamentos('[]'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum equipamento encontrado.'), findsOneWidget);
  });
}

