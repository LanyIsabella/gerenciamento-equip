import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final cargo = context.read<SessaoService>().usuario?.cargo.toLowerCase();
    return cargo == 'administrador' || cargo == 'tecnico';
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
      description: '${itens.length} ordens retornadas pela API.',
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
                  ? _Cards(itens, podeGerenciar, _abrirFormulario, _excluir,
                      _encerrar)
                  : _Tabela(itens, podeGerenciar, _abrirFormulario, _excluir,
                      _encerrar),
            ),
        ],
      ),
    );
  }

  Future<void> _abrirFormulario([Manutencao? existente]) async {
    final listaEquipamentos = equipamentos?.itens ?? const [];
    final dados = await showManutencaoForm(
      context,
      equipamentos: listaEquipamentos,
      inicial: existente,
    );
    if (dados == null || !mounted || service == null) return;
    final sucesso = existente == null
        ? await service!.criar(dados)
        : await service!.atualizar(existente.id, dados);
    if (mounted) {
      _avisar(sucesso
          ? 'Manutenção salva com sucesso.'
          : service!.erro ?? 'Não foi possível salvar.');
    }
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

class _Tabela extends StatelessWidget {
  final List<Manutencao> itens;
  final bool podeGerenciar;
  final ValueChanged<Manutencao> editar;
  final ValueChanged<Manutencao> excluir;
  final ValueChanged<Manutencao> encerrar;

  const _Tabela(
      this.itens, this.podeGerenciar, this.editar, this.excluir, this.encerrar);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Equipamento')),
            DataColumn(label: Text('Descrição')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Abertura')),
            DataColumn(label: Text('Custo')),
            DataColumn(label: Text('Responsável')),
            DataColumn(label: Text('Ações')),
          ],
          rows: itens
              .map(
                (item) => DataRow(cells: [
                  DataCell(Text(item.id.toString())),
                  DataCell(Text(item.equipamento.nome)),
                  DataCell(Text(item.descricao)),
                  DataCell(Text(item.tipo)),
                  DataCell(StatusBadge(item.status)),
                  DataCell(Text(item.dataAbertura)),
                  DataCell(Text('R\$ ${item.custo.toStringAsFixed(2)}')),
                  DataCell(Text(item.responsavel.nome)),
                  DataCell(
                      _Acoes(item, podeGerenciar, editar, excluir, encerrar)),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _Cards extends StatelessWidget {
  final List<Manutencao> itens;
  final bool podeGerenciar;
  final ValueChanged<Manutencao> editar;
  final ValueChanged<Manutencao> excluir;
  final ValueChanged<Manutencao> encerrar;

  const _Cards(
      this.itens, this.podeGerenciar, this.editar, this.excluir, this.encerrar);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: itens
          .map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.build_outlined),
                title: Text(item.equipamento.nome),
                subtitle: Text('${item.tipo} · ${item.dataAbertura}'),
                trailing:
                    _Acoes(item, podeGerenciar, editar, excluir, encerrar),
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
  final ValueChanged<Manutencao> editar;
  final ValueChanged<Manutencao> excluir;
  final ValueChanged<Manutencao> encerrar;

  const _Acoes(
      this.item, this.podeGerenciar, this.editar, this.excluir, this.encerrar);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
