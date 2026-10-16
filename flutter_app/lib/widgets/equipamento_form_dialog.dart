import 'package:flutter/material.dart';

import '../data/date_format.dart';
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
  Future<String?> Function(EquipamentoInput dados)? onSubmit,
}) async {
  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController(text: inicial?.nome);
  final descricao = TextEditingController(text: inicial?.descricao);
  final data = TextEditingController(
    text: formatarDataBr(inicial?.dataAquisicao),
  );
  final patrimonio = TextEditingController(text: inicial?.patrimonio);
  var categoriaId = inicial?.categoria.id ?? 1;
  var status = inicial?.status ?? statusDoFormulario.first;
  var salvando = false;
  String? erroApi;

  final resultado = await showDialog<EquipamentoInput>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title:
            Text(inicial == null ? 'Novo equipamento' : 'Editar equipamento'),
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
                  TextFormField(
                    controller: nome,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o nome do equipamento.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descricao,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe a descrição do equipamento.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: patrimonio,
                    decoration: const InputDecoration(labelText: 'Patrimônio'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o patrimônio do equipamento.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: data,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [DataBrInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Data de aquisição (DD/MM/AAAA)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a data de aquisição.';
                      }
                      return dataBrValida(value)
                          ? null
                          : 'Use uma data válida no formato DD/MM/AAAA.';
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: categoriaId,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: categoriasDoFormulario.entries
                        .map((item) => DropdownMenuItem(
                              value: item.key,
                              child: Text(item.value),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => categoriaId = value!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: statusDoFormulario
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => status = value!),
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

                    final dados = EquipamentoInput(
                      nome: nome.text.trim(),
                      descricao: descricao.text.trim(),
                      dataAquisicao: converterDataParaApi(data.text),
                      patrimonio: patrimonio.text.trim(),
                      status: status,
                      idCategoria: categoriaId,
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

  nome.dispose();
  descricao.dispose();
  data.dispose();
  patrimonio.dispose();
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
