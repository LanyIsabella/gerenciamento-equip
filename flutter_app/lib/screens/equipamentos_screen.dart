import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/date_format.dart';
import '../models/equipamento.dart';
import '../services/equipamentos_service.dart';
import '../services/sessao_service.dart';
import '../routes.dart';
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
    return context
            .read<SessaoService>()
            .usuario
            ?.cargo
            .podeGerenciarEquipamentos ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EquipamentosService?>();
    final itens = estado?.itens ?? const <Equipamento>[];

    return AppShell(
      title: 'Equipamentos',
      description: '${itens.length} equipamentos cadastrados.',
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
                  ? _Cards(itens, podeGerenciar, _abrirDetalhe, _abrirFormulario,
                      _excluir)
                  : _Tabela(itens, podeGerenciar, _abrirDetalhe, _abrirFormulario, _excluir),
            ),
        ],
      ),
    );
  }

  Future<void> _abrirFormulario([Equipamento? existente]) async {
    if (service == null) return;
    final dados = await showEquipamentoForm(
      context,
      inicial: existente,
      onSubmit: (dados) async {
        final sucesso = existente == null
            ? await service!.criar(dados)
            : await service!.atualizar(existente.id, dados);
        return sucesso
            ? null
            : service!.erro ?? 'Não foi possível salvar o equipamento.';
      },
    );
    if (dados != null && mounted) _avisar('Equipamento salvo com sucesso.');
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
            Text('Aquisição: ${formatarDataBr(equipamento.dataAquisicao)}'),
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

  void _abrirDetalhe(Equipamento equipamento) {
    Navigator.pushNamed(context, AppRoutes.equipamentoDetalhe, arguments: equipamento.id);
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

class _Tabela extends StatefulWidget {
  final List<Equipamento> itens;
  final bool podeGerenciar;
  final ValueChanged<Equipamento> editar;
  final ValueChanged<Equipamento> excluir;

  const _Tabela(this.itens, this.podeGerenciar, this.detalhes, this.editar, this.excluir);

  @override
  State<_Tabela> createState() => _TabelaState();
}

class _TabelaState extends State<_Tabela> {
  int? expandida;

  Map<int, TableColumnWidth> get _colunas => const {
        0: FlexColumnWidth(0.5),
        1: FlexColumnWidth(2.4),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.2),
        4: FlexColumnWidth(1.8),
        5: FlexColumnWidth(2.1),
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Table(
              columnWidths: _colunas,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    'ID',
                    'Nome',
                    'Patrimônio',
                    'Status',
                    'Responsável',
                    'Ações',
                  ].map(_cabecalho).toList(),
                ),
              ],
            ),
          ),
          for (final item in widget.itens)
            _LinhaTabelaEquipamento(
              item: item,
              podeGerenciar: widget.podeGerenciar,
              expandida: expandida == item.id,
              colunas: _colunas,
              onDetalhes: () => widget.detalhes(item),
              onEditar: () => widget.editar(item),
              onExcluir: () => widget.excluir(item),
            ),
        ],
      ),
    );
  }

  Widget _cabecalho(String texto) {
    return Text(texto, style: const TextStyle(fontWeight: FontWeight.w700));
  }
}

class _LinhaTabelaEquipamento extends StatelessWidget {
  final Equipamento item;
  final bool podeGerenciar;
  final bool expandida;
  final Map<int, TableColumnWidth> colunas;
  final VoidCallback onDetalhes;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _LinhaTabelaEquipamento({
    required this.item,
    required this.podeGerenciar,
    required this.expandida,
    required this.colunas,
    required this.onDetalhes,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Table(
            columnWidths: colunas,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  Text(item.id.toString()),
                  Text(item.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(item.patrimonio,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusBadge(item.status),
                  ),
                  Text(item.responsavel.nome,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  _acoes(context),
                ],
              ),
            ],
          ),
        ),
        if (expandida)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 28,
              runSpacing: 8,
              children: [
                _DetalheEquipamento(
                  label: 'Aquisição',
                  value: formatarDataBr(item.dataAquisicao),
                ),
                _DetalheEquipamento(
                  label: 'Categoria',
                  value: item.categoria.nome,
                ),
                _DetalheEquipamento(
                  label: 'Patrimônio',
                  value: item.patrimonio,
                ),
                _DetalheEquipamento(
                  label: 'Responsável',
                  value: item.responsavel.nome,
                ),
              ],
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _acoes(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton.icon(
          onPressed: onDetalhes,
          icon: Icon(
            expandida ? Icons.keyboard_arrow_up : Icons.visibility_outlined,
            size: 18,
          ),
          label: Text(expandida ? 'Ocultar' : 'Detalhes'),
        ),
        if (podeGerenciar)
          IconButton(
            tooltip: 'Editar',
            onPressed: onEditar,
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
        if (podeGerenciar)
          IconButton(
            tooltip: 'Excluir',
            onPressed: onExcluir,
            icon: const Icon(Icons.delete_outline, size: 20),
          ),
      ],
    );
  }
}

class _DetalheEquipamento extends StatelessWidget {
  final String label;
  final String value;

  const _DetalheEquipamento({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.inventory_2_outlined),
                        ),
                        Expanded(
                          child: Text(
                            item.nome,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(item.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${item.patrimonio} · ${item.categoria.nome}'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => detalhes(item),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Ver detalhes'),
                      ),
                    ),
                    if (podeGerenciar) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _Acoes(
                          item,
                          podeGerenciar,
                          detalhes,
                          editar,
                          excluir,
                          mostrarDetalhes: false,
                        ),
                      ),
                    ],
                  ],
                ),
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
  final bool mostrarDetalhes;

  const _Acoes(
      this.item, this.podeGerenciar, this.detalhes, this.editar, this.excluir,
      {this.mostrarDetalhes = true});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      children: [
        if (mostrarDetalhes)
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
  final ValueChanged<Equipamento> detalhes;
