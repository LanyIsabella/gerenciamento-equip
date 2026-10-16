import 'package:flutter/material.dart';

import '../data/date_format.dart';
import '../models/equipamento.dart';
import '../models/manutencao.dart';

const tiposDoFormulario = ['Preventiva', 'Corretiva'];
const statusDaManutencao = ['Pendente', 'Em Andamento', 'Concluída'];

Future<ManutencaoInput?> showManutencaoForm(
  BuildContext context, {
  required List<Equipamento> equipamentos,
  Manutencao? inicial,
  Future<String?> Function(ManutencaoInput dados)? onSubmit,
}) async {
  final formKey = GlobalKey<FormState>();
  final descricao = TextEditingController(text: inicial?.descricao);
  final custo = TextEditingController(
    text: inicial?.custo.toString() ?? '0',
  );
  final abertura = TextEditingController(
    text: formatarDataBr(inicial?.dataAbertura),
  );
  final conclusao = TextEditingController(
    text: formatarDataBr(inicial?.dataConclusao),
  );
  var equipamento = inicial?.idEquipamento ?? equipamentos.firstOrNull?.id;
  var tipo = inicial?.tipo ?? tiposDoFormulario.first;
  var status = inicial?.status ?? statusDaManutencao.first;
  var salvando = false;
  String? erroApi;

  if (equipamento == null) return null;

  final resultado = await showDialog<ManutencaoInput>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(inicial == null ? 'Nova manutenção' : 'Editar manutenção'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (erroApi != null) ...[
                    _ErroFormulario(erroApi!),
                    const SizedBox(height: 10),
                  ],
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
                    validator: (value) => value == null
                        ? 'Selecione o equipamento da manutenção.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descricao,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe a descrição da manutenção.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: tipo,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: tiposDoFormulario
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => tipo = value!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: statusDaManutencao
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => status = value!),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: abertura,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [DataBrInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Data de abertura (DD/MM/AAAA)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a data de abertura.';
                      }
                      return dataBrValida(value)
                          ? null
                          : 'Use uma data válida no formato DD/MM/AAAA.';
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: conclusao,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [DataBrInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Data de conclusão (DD/MM/AAAA, opcional)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      return dataBrValida(value)
                          ? null
                          : 'Use uma data válida no formato DD/MM/AAAA.';
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: custo,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Custo'),
                    validator: (value) =>
                        double.tryParse(value?.replaceAll(',', '.') ?? '') ==
                                null
                            ? 'Informe um custo numérico válido.'
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: salvando ? null : () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: salvando
                ? null
                : () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;

                    final dados = ManutencaoInput(
                      idEquipamento: equipamento!,
                      descricao: descricao.text.trim(),
                      status: status,
                      tipo: tipo,
                      custo: double.parse(custo.text.replaceAll(',', '.')),
                      dataAbertura: converterDataParaApi(abertura.text),
                      dataConclusao: conclusao.text.trim().isEmpty
                          ? null
                          : converterDataParaApi(conclusao.text),
                    );

                    if (onSubmit == null) {
                      Navigator.pop(dialogContext, dados);
                      return;
                    }

                    setState(() {
                      salvando = true;
                      erroApi = null;
                    });
                    final erro = await onSubmit(dados);
                    if (!dialogContext.mounted) return;
                    setState(() => salvando = false);
                    if (erro != null) {
                      setState(() => erroApi = erro);
                    } else {
                      Navigator.pop(dialogContext, dados);
                    }
                  },
            child: Text(salvando ? 'Salvando...' : 'Salvar'),
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

class _ErroFormulario extends StatelessWidget {
  final String mensagem;

  const _ErroFormulario(this.mensagem);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        mensagem,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}
