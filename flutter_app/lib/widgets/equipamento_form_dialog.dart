import 'package:flutter/material.dart';

import '../models/equipamento.dart';

const categoriasDoFormulario = <int, String>{
  1: 'Máquinas Pesadas',
  2: 'Ferramentas Elétricas',
  3: 'Equipamentos de TI',
  4: 'Veículos Industriais',
  5: 'Instrumentos de Medição',
};

const statusDoFormulario = ['Ativo', 'Em Manutenção', 'Inativo'];

Future<EquipamentoInput?> showEquipamentoForm(
  BuildContext context, {
  Equipamento? inicial,
}) async {
  final nome = TextEditingController(text: inicial?.nome);
  final descricao = TextEditingController(text: inicial?.descricao);
  final data = TextEditingController(text: inicial?.dataAquisicao);
  final patrimonio = TextEditingController(text: inicial?.patrimonio);
  var categoria = inicial?.categoria.nome ?? categoriasDoFormulario[1]!;
  var status = inicial?.status ?? statusDoFormulario.first;

  final resultado = await showDialog<EquipamentoInput>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title:
            Text(inicial == null ? 'Novo equipamento' : 'Editar equipamento'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descricao,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: patrimonio,
                  decoration: const InputDecoration(labelText: 'Patrimônio'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: data,
                  decoration: const InputDecoration(
                    labelText: 'Data de aquisição (AAAA-MM-DD)',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: categoria,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: categoriasDoFormulario.values
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => categoria = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: statusDoFormulario
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => status = value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final idCategoria = categoriasDoFormulario.entries
                  .firstWhere((item) => item.value == categoria)
                  .key;
              Navigator.pop(
                dialogContext,
                EquipamentoInput(
                  nome: nome.text.trim(),
                  descricao: descricao.text.trim(),
                  dataAquisicao: data.text.trim(),
                  patrimonio: patrimonio.text.trim(),
                  status: status,
                  idCategoria: idCategoria,
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    ),
  );

  nome.dispose();
  descricao.dispose();
  data.dispose();
  patrimonio.dispose();
  return resultado;
}
