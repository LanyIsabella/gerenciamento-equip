import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:equip_control_app/models/equipamento.dart';
import 'package:equip_control_app/repositories/equipamentos_repository.dart';
import 'package:equip_control_app/screens/equipamentos_screen.dart';
import 'package:equip_control_app/services/equipamentos_service.dart';
import 'package:equip_control_app/services/sessao_service.dart';

import 'fake_auth_repository.dart';

class FakeEquipamentosRepository implements EquipamentosRepository {
  @override
  Future<List<Equipamento>> listar({
    String? busca,
    int? idCategoria,
    String? status,
  }) async {
    return const [
      Equipamento(
        id: 1,
        nome: 'Torno CNC',
        descricao: 'Equipamento de produção',
        dataAquisicao: '2025-01-01',
        patrimonio: 'PAT-1',
        status: 'Ativo',
        categoria: CategoriaResumo(id: 1, nome: 'Máquinas'),
        responsavel: UsuarioResumo(id: 1, nome: 'Ana', cargo: 'gerente'),
      ),
    ];
  }

  @override
  Future<Equipamento> criar(EquipamentoInput dados) =>
      throw UnimplementedError();

  @override
  Future<Equipamento> atualizar(int id, EquipamentoInput dados) =>
      throw UnimplementedError();

  @override
  Future<void> excluir(int id) => throw UnimplementedError();
}

void main() {
  testWidgets('tela de equipamentos exibe resposta do service', (tester) async {
    final sessao = SessaoService(FakeAuthRepository());
    await sessao.entrar('teste@exemplo.com', 'senha123');
    final service = EquipamentosService(
      FakeEquipamentosRepository(),
      sessao,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sessao),
          ChangeNotifierProvider.value(value: service),
        ],
        child: const MaterialApp(home: EquipamentosScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Torno CNC'), findsOneWidget);
    expect(find.textContaining('PAT-1'), findsOneWidget);
  });
}
