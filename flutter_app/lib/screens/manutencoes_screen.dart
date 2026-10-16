import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/date_format.dart';
import '../models/manutencao.dart';
import '../services/equipamentos_service.dart';
import '../services/manutencoes_service.dart';
import '../services/sessao_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/manutencao_form_dialog.dart';
import '../widgets/status_badge.dart';

const _tipos = ['Todos os tipos', 'Preventiva', 'Corretiva'];
const _status = ['Todos os status', 'Pendente', 'Em Andamento', 'Concluída'];

class ManutencoesScreen extends StatefulWidget {
  const ManutencoesScreen({super.key});

  @override
  State<ManutencoesScreen> createState() => _ManutencoesScreenState();
}

class _ManutencoesScreenState extends State<ManutencoesScreen> {
  String equipamento = 'Todos os equipamentos';
  String tipo = _tipos.first;
  String status = _status.first;

  ManutencoesService? get service => context.read<ManutencoesService?>();
  EquipamentosService? get equipamentos => context.read<EquipamentosService?>();

  bool get podeGerenciar {
    return context
            .read<SessaoService>()
            .usuario
            ?.cargo
            .podeGerenciarManutencoes ??
        false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      equipamentos?.carregar();
      _carregar();
    });
  }

  Future<void> _carregar() {
    final idEquipamento = equipamentos?.itens
        .where((item) => item.nome == equipamento)
        .map((item) => item.id)
        .firstOrNull;
    return service?.carregar(
          idEquipamento: idEquipamento,
          tipo: tipo == _tipos.first ? null : tipo,
          status: status == _status.first ? null : status,
        ) ??
        Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<ManutencoesService?>();
    final itens = estado?.itens ?? const <Manutencao>[];
    final equipamentosAtuais =
        context.watch<EquipamentosService?>()?.itens ?? const [];

    return AppShell(
      title: 'Manutenções',
      description: '${itens.length} ordens de manutenção cadastradas.',
      action: podeGerenciar
          ? ElevatedButton.icon(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Abrir nova manutenção'),
            )
          : null,
      child: Column(
        children: [
          _Filtros(
            equipamentos: equipamentosAtuais.map((item) => item.nome).toList(),
            equipamento: equipamento,
            tipo: tipo,
            status: status,
            onEquipamento: (value) {
              setState(() => equipamento = value);
              _carregar();
            },
            onTipo: (value) {
              setState(() => tipo = value);
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
                child: Center(child: Text('Nenhuma manutenção encontrada.')),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth < 820
                  ? _Cards(itens, podeGerenciar, _detalhes, _abrirFormulario,
                      _excluir, _encerrar)
                  : _Tabela(itens, podeGerenciar, _abrirFormulario, _excluir,
                      _encerrar),
            ),
        ],
      ),
    );
  }

  Future<void> _abrirFormulario([Manutencao? existente]) async {
    final listaEquipamentos = equipamentos?.itens ?? const [];
    if (service == null) return;
    final dados = await showManutencaoForm(
      context,
      equipamentos: listaEquipamentos,
      inicial: existente,
      onSubmit: (dados) async {
        final sucesso = existente == null
            ? await service!.criar(dados)
            : await service!.atualizar(existente.id, dados);
        return sucesso
            ? null
            : service!.erro ?? 'Não foi possível salvar a manutenção.';
      },
    );
    if (dados != null && mounted) _avisar('Manutenção salva com sucesso.');
  }

  Future<void> _excluir(Manutencao manutencao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir manutenção?'),
        content: Text('A ordem ${manutencao.id} será removida.'),
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
    final sucesso = await service!.excluir(manutencao.id);
    if (mounted) {
      _avisar(sucesso
          ? 'Manutenção excluída.'
          : service!.erro ?? 'Não foi possível excluir.');
    }
  }

  Future<void> _encerrar(Manutencao manutencao) async {
    final sucesso = await service?.encerrar(
          manutencao.id,
          DateTime.now().toIso8601String().substring(0, 10),
        ) ??
        false;
    if (mounted) {
      _avisar(sucesso
          ? 'Manutenção encerrada.'
          : service?.erro ?? 'Não foi possível encerrar.');
    }
  }

  void _detalhes(Manutencao manutencao) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Manutenção #${manutencao.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Detalhe(
                  label: 'Equipamento', value: manutencao.equipamento.nome),
              _Detalhe(label: 'Descrição', value: manutencao.descricao),
              _Detalhe(label: 'Tipo', value: manutencao.tipo),
              _Detalhe(label: 'Status', value: manutencao.status),
              _Detalhe(
                label: 'Abertura',
                value: formatarDataBr(manutencao.dataAbertura),
              ),
              _Detalhe(
                label: 'Conclusão',
                value: formatarDataBr(manutencao.dataConclusao) == ''
                    ? 'Em aberto'
                    : formatarDataBr(manutencao.dataConclusao),
              ),
              _Detalhe(
                label: 'Custo',
                value: 'R\$ ${manutencao.custo.toStringAsFixed(2)}',
              ),
              _Detalhe(
                  label: 'Responsável', value: manutencao.responsavel.nome),
            ],
          ),
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
  final List<String> equipamentos;
  final String equipamento;
  final String tipo;
  final String status;
  final ValueChanged<String> onEquipamento;
  final ValueChanged<String> onTipo;
  final ValueChanged<String> onStatus;

  const _Filtros({
    required this.equipamentos,
    required this.equipamento,
    required this.tipo,
    required this.status,
    required this.onEquipamento,
    required this.onTipo,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final equipamentosOptions = ['Todos os equipamentos', ...equipamentos];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Campo(
              label: 'Equipamento',
              value: equipamento,
              items: equipamentosOptions,
              onChanged: onEquipamento,
            ),
            _Campo(
              label: 'Tipo',
              value: tipo,
              items: _tipos,
              onChanged: onTipo,
            ),
            _Campo(
              label: 'Status',
              value: status,
              items: _status,
              onChanged: onStatus,
            ),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _Campo({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (selected) => onChanged(selected!),
      ),
    );
  }
}

class _Tabela extends StatefulWidget {
  final List<Manutencao> itens;
  final bool podeGerenciar;
  final ValueChanged<Manutencao> editar;
  final ValueChanged<Manutencao> excluir;
  final ValueChanged<Manutencao> encerrar;

  const _Tabela(
      this.itens, this.podeGerenciar, this.editar, this.excluir, this.encerrar);

  @override
  State<_Tabela> createState() => _TabelaState();
}

class _TabelaState extends State<_Tabela> {
  int? expandida;

  Map<int, TableColumnWidth> get _colunas => const {
        0: FlexColumnWidth(0.5),
        1: FlexColumnWidth(2.4),
        2: FlexColumnWidth(1.1),
        3: FlexColumnWidth(1.2),
        4: FlexColumnWidth(1.2),
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
                    'Equipamento',
                    'Tipo',
                    'Status',
                    'Abertura',
                    'Ações'
                  ].map(_cabecalho).toList(),
                ),
              ],
            ),
          ),
          for (final item in widget.itens)
            _LinhaTabela(
              item: item,
              podeGerenciar: widget.podeGerenciar,
              expandida: expandida == item.id,
              colunas: _colunas,
              onDetalhes: () => setState(
                () => expandida = expandida == item.id ? null : item.id,
              ),
              onEditar: () => widget.editar(item),
              onExcluir: () => widget.excluir(item),
              onEncerrar: () => widget.encerrar(item),
            ),
        ],
      ),
    );
  }

  Widget _cabecalho(String texto) {
    return Text(texto, style: const TextStyle(fontWeight: FontWeight.w700));
  }
}

class _LinhaTabela extends StatelessWidget {
  final Manutencao item;
  final bool podeGerenciar;
  final bool expandida;
  final Map<int, TableColumnWidth> colunas;
  final VoidCallback onDetalhes;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onEncerrar;

  const _LinhaTabela({
    required this.item,
    required this.podeGerenciar,
    required this.expandida,
    required this.colunas,
    required this.onDetalhes,
    required this.onEditar,
    required this.onExcluir,
    required this.onEncerrar,
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
                  Text(item.equipamento.nome,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(item.tipo, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusBadge(item.status),
                  ),
                  Text(formatarDataBr(item.dataAbertura),
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
                _Detalhe(label: 'Descrição', value: item.descricao),
                _Detalhe(
                  label: 'Custo',
                  value: 'R\$ ${item.custo.toStringAsFixed(2)}',
                ),
                _Detalhe(label: 'Responsável', value: item.responsavel.nome),
                _Detalhe(
                  label: 'Conclusão',
                  value: formatarDataBr(item.dataConclusao) == ''
                      ? 'Em aberto'
                      : formatarDataBr(item.dataConclusao),
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
        if (podeGerenciar && item.status != 'Concluída')
          IconButton(
            tooltip: 'Encerrar',
            onPressed: onEncerrar,
            icon: const Icon(Icons.check_circle_outline, size: 20),
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

class _Cards extends StatelessWidget {
  final List<Manutencao> itens;
  final bool podeGerenciar;
  final ValueChanged<Manutencao> detalhes;
  final ValueChanged<Manutencao> editar;
  final ValueChanged<Manutencao> excluir;
  final ValueChanged<Manutencao> encerrar;

  const _Cards(this.itens, this.podeGerenciar, this.detalhes, this.editar,
      this.excluir, this.encerrar);

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
                          child: Icon(Icons.build_outlined),
                        ),
                        Expanded(
                          child: Text(
                            item.equipamento.nome,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(item.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${item.tipo} · ${formatarDataBr(item.dataAbertura)}'),
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
                          encerrar,
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
  final Manutencao item;
  final bool podeGerenciar;
  final ValueChanged<Manutencao> detalhes;
  final ValueChanged<Manutencao> editar;
  final ValueChanged<Manutencao> excluir;
  final ValueChanged<Manutencao> encerrar;
  final bool mostrarDetalhes;

  const _Acoes(this.item, this.podeGerenciar, this.detalhes, this.editar,
      this.excluir, this.encerrar,
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
        if (podeGerenciar)
          IconButton(
            tooltip: 'Editar',
            onPressed: () => editar(item),
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
        if (podeGerenciar && item.status != 'Concluída')
          IconButton(
            tooltip: 'Encerrar',
            onPressed: () => encerrar(item),
            icon: const Icon(Icons.check_circle_outline, size: 20),
          ),
        if (podeGerenciar)
          IconButton(
            tooltip: 'Excluir',
            onPressed: () => excluir(item),
            icon: const Icon(Icons.delete_outline, size: 20),
          ),
      ],
    );
  }
}

class _Detalhe extends StatelessWidget {
  final String label;
  final String value;

  const _Detalhe({required this.label, required this.value});

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
