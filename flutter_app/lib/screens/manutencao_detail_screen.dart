import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/date_format.dart';
import '../services/manutencoes_service.dart';
import '../widgets/status_badge.dart';

class ManutencaoDetailScreen extends StatefulWidget {
  final int id;

  const ManutencaoDetailScreen({super.key, required this.id});

  @override
  State<ManutencaoDetailScreen> createState() => _ManutencaoDetailScreenState();
}

class _ManutencaoDetailScreenState extends State<ManutencaoDetailScreen> {
  late Future<void> _carregamento;

  @override
  void initState() {
    super.initState();
    _carregamento = _buscar();
  }

  Future<void> _buscar() async {
    await context.read<ManutencoesService>().buscarPorId(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ManutencoesService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da manutenção')),
      body: FutureBuilder<void>(
        future: _carregamento,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = service.itens.where((value) => value.id == widget.id).firstOrNull;
          if (item == null) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(service.erro ?? 'Manutenção não encontrada.'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => setState(() => _carregamento = _buscar()), child: const Text('Tentar de novo')),
              ]),
            );
          }
          return ListView(padding: const EdgeInsets.all(24), children: [
            Text(item.descricao, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            StatusBadge(item.status),
            const SizedBox(height: 20),
            Text('Equipamento: ${item.equipamento.nome} (${item.equipamento.patrimonio})'),
            Text('Tipo: ${item.tipo}'),
            Text('Custo: ${item.custo.toStringAsFixed(2)}'),
            Text('Abertura: ${formatarDataBr(item.dataAbertura)}'),
            if (item.dataConclusao != null) Text('Conclusão: ${formatarDataBr(item.dataConclusao!)}'),
            Text('Responsável: ${item.responsavel.nome}'),
          ]);
        },
      ),
    );
  }
}
