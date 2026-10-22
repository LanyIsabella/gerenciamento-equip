import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/date_format.dart';
import '../services/equipamentos_service.dart';
import '../widgets/status_badge.dart';

class EquipamentoDetailScreen extends StatefulWidget {
  final int id;

  const EquipamentoDetailScreen({super.key, required this.id});

  @override
  State<EquipamentoDetailScreen> createState() => _EquipamentoDetailScreenState();
}

class _EquipamentoDetailScreenState extends State<EquipamentoDetailScreen> {
  late Future<void> _carregamento;

  @override
  void initState() {
    super.initState();
    _carregamento = _buscar();
  }

  Future<void> _buscar() async {
    final equipamento = await context.read<EquipamentosService>().buscarPorId(widget.id);
    if (!mounted) return;
    if (equipamento == null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<EquipamentosService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do equipamento')),
      body: FutureBuilder<void>(
        future: _carregamento,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final equipamento = service.itens.where((item) => item.id == widget.id).firstOrNull;
          if (equipamento == null) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(service.erro ?? 'Equipamento não encontrado.'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => setState(() => _carregamento = _buscar()), child: const Text('Tentar de novo')),
              ]),
            );
          }
          return ListView(padding: const EdgeInsets.all(24), children: [
            Text(equipamento.nome, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            StatusBadge(equipamento.status),
            const SizedBox(height: 20),
            Text('Descrição: ${equipamento.descricao}'),
            Text('Patrimônio: ${equipamento.patrimonio}'),
            Text('Categoria: ${equipamento.categoria.nome}'),
            Text('Aquisição: ${formatarDataBr(equipamento.dataAquisicao)}'),
            Text('Responsável: ${equipamento.responsavel.nome}'),
          ]);
        },
      ),
    );
  }
}
