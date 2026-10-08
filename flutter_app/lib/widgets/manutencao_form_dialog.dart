import 'package:flutter/material.dart';

import '../models/equipamento.dart';
import '../models/manutencao.dart';

const tiposDoFormulario = ['Preventiva', 'Corretiva'];
const statusDaManutencao = ['Pendente', 'Em Andamento', 'Concluída'];

Future<ManutencaoInput?> showManutencaoForm(
  BuildContext context, {
  required List<Equipamento> equipamentos,
  Manutencao? inicial,
}) async {
  final descricao = TextEditingController(text: inicial?.descricao);
  final custo = TextEditingController(
    text: inicial?.custo.toString() ?? '0',
  );
  final abertura = TextEditingController(text: inicial?.dataAbertura);
  final conclusao = TextEditingController(text: inicial?.dataConclusao);
  var equipamento = inicial?.idEquipamento ?? equipamentos.firstOrNull?.id;
  var tipo = inicial?.tipo ?? tiposDoFormulario.first;
  var status = inicial?.status ?? statusDaManutencao.first;

  if (equipamento == null) return null;

  final resultado = await showDialog<ManutencaoInput>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(inicial == null ? 'Nova manutenção' : 'Editar manutenção'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: equipamento,
                  decoration: const InputDecoration(labelText: 'Equipamento'),
                  items: equipamentos
                      .map((item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.nome),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => equipamento = value),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descricao,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: tiposDoFormulario
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => tipo = value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: statusDaManutencao
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => status = value!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: abertura,
                  decoration: const InputDecoration(
                    labelText: 'Data de abertura (AAAA-MM-DD)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: conclusao,
                  decoration: const InputDecoration(
                    labelText: 'Data de conclusão (opcional)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: custo,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Custo'),
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
              Navigator.pop(
                dialogContext,
                ManutencaoInput(
                  idEquipamento: equipamento!,
                  descricao: descricao.text.trim(),
                  status: status,
                  tipo: tipo,
                  custo: double.tryParse(custo.text.replaceAll(',', '.')) ?? 0,
                  dataAbertura: abertura.text.trim(),
                  dataConclusao: conclusao.text.trim().isEmpty
                      ? null
                      : conclusao.text.trim(),
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    ),
  );

  descricao.dispose();
  custo.dispose();
  abertura.dispose();
  conclusao.dispose();
  return resultado;
}
