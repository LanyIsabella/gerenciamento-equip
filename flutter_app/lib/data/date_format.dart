import 'package:flutter/services.dart';

String formatarDataBr(String? data) {
  if (data == null || data.isEmpty) return '';

  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(data);
  if (iso == null) return data;
  return '${iso.group(3)}/${iso.group(2)}/${iso.group(1)}';
}

String converterDataParaApi(String data) {
  final partes = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(data.trim());
  if (partes == null) return data.trim();

  return '${partes.group(3)}-${partes.group(2)}-${partes.group(1)}';
}

bool dataBrValida(String data) {
  final partes = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(data.trim());
  if (partes == null) return false;

  final dia = int.parse(partes.group(1)!);
  final mes = int.parse(partes.group(2)!);
  final ano = int.parse(partes.group(3)!);
  final dataConvertida = DateTime(ano, mes, dia);
  return dataConvertida.year == ano &&
      dataConvertida.month == mes &&
      dataConvertida.day == dia;
}

class DataBrInputFormatter extends TextInputFormatter {
  const DataBrInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final numeros = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitados = numeros.length > 8 ? numeros.substring(0, 8) : numeros;
    final partes = <String>[];

    if (limitados.length >= 2) {
      partes.add(limitados.substring(0, 2));
    } else if (limitados.isNotEmpty) {
      partes.add(limitados);
    }
    if (limitados.length >= 4) {
      partes.add(limitados.substring(2, 4));
    } else if (limitados.length > 2) {
      partes.add(limitados.substring(2));
    }
    if (limitados.length > 4) {
      partes.add(limitados.substring(4));
    }

    final formatado = partes.join('/');
    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );
  }
}
