import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/equipamento.dart';
import '../services/equipamentos_service.dart';
import '../services/sessao_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/equipamento_form_dialog.dart';
import '../widgets/status_badge.dart';

const _categorias = <int, String>{
  1: 'Máquinas Pesadas',
  2: 'Ferramentas Elétricas',
  3: 'Equipamentos de TI',
  4: 'Veículos Industriais',
  5: 'Instrumentos de Medição',
};
const _status = ['Todos os status', 'Ativo', 'Em Manutenção', 'Inativo'];

class EquipamentosScreen extends StatefulWidget {
  const EquipamentosScreen({super.key});

  @override
  State<EquipamentosScreen> createState() => _EquipamentosScreenState();
}

class _EquipamentosScreenState extends State<EquipamentosScreen> {
  final busca = TextEditingController();
  String categoria = 'Todas as categorias';
  String status = _status.first;

  EquipamentosService? get service => context.read<EquipamentosService?>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }

  Future<void> _carregar() {
    final idCategoria = _categorias.entries
        .where((item) => item.value == categoria)
        .map((item) => item.key)
        .firstOrNull;
    return service?.carregar(
          busca: busca.text,
          idCategoria: idCategoria,
          status: status == _status.first ? null : status,
        ) ??
        Future<void>.value();
  }

  bool get podeGerenciar {
    final cargo = context.read<SessaoService>().usuario?.cargo.toLowerCase();
    return cargo == 'administrador' || cargo == 'gerente' || cargo == 'gestor';
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EquipamentosService?>();
    final itens = estado?.itens ?? const <Equipamento>[];

    return AppShell(
      title: 'Equipamentos',
      description: '${itens.length} equipamentos retornados pela API.',
      action: podeGerenciar
          ? ElevatedButton.icon(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo equipamento'),
            )
          : null,
      child: Column(
        children: [
          _Filtros(
            busca: busca,
            categoria: categoria,
            status: status,
            onBusca: (_) => _carregar(),
            onCategoria: (value) {
              setState(() => categoria = value);
              _carregar();
            },
            onStatus: (value) {
              setState(() => status = value);
              _carregar();
            },
          ),
          if (estado?.erro != null) _Erro(estado!.erro!),
          if (estado?.carregando == true) const LinearProgressIndicator(),
          const SizedBox(height: 16),
          if (itens.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: Text('Nenhum equipamento encontrado.')),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth < 760
                  ? _Cards(itens, podeGerenciar, _detalhes, _abrirFormulario,
                      _excluir)
                  : _Tabela(itens, podeGerenciar, _detalhes, _abrirFormulario,
                      _excluir),
            ),
        ],
      ),
    );
  }

  Future<void> _abrirFormulario([Equipamento? existente]) async {
    final dados = await showEquipamentoForm(context, inicial: existente);
    if (dados == null || !mounted || service == null) return;
    final sucesso = existente == null
        ? await service!.criar(dados)
        : await service!.atualizar(existente.id, dados);
    if (mounted) {
      _avisar(sucesso
          ? 'Equipamento salvo com sucesso.'
          : service!.erro ?? 'Não foi possível salvar o equipamento.');
    }
  }

  Future<void> _excluir(Equipamento equipamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir equipamento?'),
        content: Text('“${equipamento.nome}” será removido permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted || service == null) return;
    final sucesso = await service!.excluir(equipamento.id);
    if (mounted) {
      _avisar(sucesso
          ? 'Equipamento excluído.'
          : service!.erro ?? 'Não foi possível excluir.');
    }
  }

  void _detalhes(Equipamento equipamento) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(equipamento.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patrimônio: ${equipamento.patrimonio}'),
            Text('Categoria: ${equipamento.categoria.nome}'),
            Text('Aquisição: ${equipamento.dataAquisicao}'),
            Text('Responsável: ${equipamento.responsavel.nome}'),
            const SizedBox(height: 10),
            StatusBadge(equipamento.status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

class _Filtros extends StatelessWidget {
  final TextEditingController busca;
  final String categoria;
  final String status;
  final ValueChanged<String> onBusca;
  final ValueChanged<String> onCategoria;
  final ValueChanged<String> onStatus;

  const _Filtros({
    required this.busca,
    required this.categoria,
    required this.status,
    required this.onBusca,
    required this.onCategoria,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final categorias = ['Todas as categorias', ..._categorias.values];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: busca,
                onChanged: onBusca,
                decoration: const InputDecoration(
                  labelText: 'Buscar por nome ou patrimônio',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(
              width: 230,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: categoria,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: categorias
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => onCategoria(value!),
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _status
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => onStatus(value!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tabela extends StatelessWidget {
  final List<Equipamento> itens;
  final bool podeGerenciar;
  final ValueChanged<Equipamento> detalhes;
  final ValueChanged<Equipamento> editar;
  final ValueChanged<Equipamento> excluir;

  const _Tabela(
      this.itens, this.podeGerenciar, this.detalhes, this.editar, this.excluir);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('Patrimônio')),
            DataColumn(label: Text('Aquisição')),
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Responsável')),
            DataColumn(label: Text('Ações')),
          ],
          rows: itens
              .map(
                (item) => DataRow(cells: [
                  DataCell(Text(item.id.toString())),
                  DataCell(Text(item.nome)),
                  DataCell(Text(item.patrimonio)),
                  DataCell(Text(item.dataAquisicao)),
                  DataCell(Text(item.categoria.nome)),
                  DataCell(StatusBadge(item.status)),
                  DataCell(Text(item.responsavel.nome)),
                  DataCell(
                      _Acoes(item, podeGerenciar, detalhes, editar, excluir)),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _Cards extends StatelessWidget {
  final List<Equipamento> itens;
  final bool podeGerenciar;
  final ValueChanged<Equipamento> detalhes;
  final ValueChanged<Equipamento> editar;
  final ValueChanged<Equipamento> excluir;

  const _Cards(
      this.itens, this.podeGerenciar, this.detalhes, this.editar, this.excluir);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: itens
          .map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(item.nome),
                subtitle: Text('${item.patrimonio} · ${item.categoria.nome}'),
                trailing:
                    _Acoes(item, podeGerenciar, detalhes, editar, excluir),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Acoes extends StatelessWidget {
  final Equipamento item;
  final bool podeGerenciar;
  final ValueChanged<Equipamento> detalhes;
  final ValueChanged<Equipamento> editar;
  final ValueChanged<Equipamento> excluir;

  const _Acoes(
      this.item, this.podeGerenciar, this.detalhes, this.editar, this.excluir);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Ver detalhes',
          onPressed: () => detalhes(item),
          icon: const Icon(Icons.visibility_outlined, size: 20),
        ),
        if (podeGerenciar) ...[
          IconButton(
            tooltip: 'Editar',
            onPressed: () => editar(item),
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Excluir',
            onPressed: () => excluir(item),
            icon: const Icon(Icons.delete_outline, size: 20),
          ),
        ],
      ],
    );
  }
}

class _Erro extends StatelessWidget {
  final String mensagem;

  const _Erro(this.mensagem);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        mensagem,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
