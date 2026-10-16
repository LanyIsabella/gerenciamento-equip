import 'package:flutter_test/flutter_test.dart';

import 'package:equip_control_app/data/date_format.dart';

void main() {
  test('converte datas da API para o padrão brasileiro', () {
    expect(formatarDataBr('2026-10-15'), '15/10/2026');
    expect(formatarDataBr(null), '');
  });

  test('converte datas brasileiras para o formato da API', () {
    expect(converterDataParaApi('15/10/2026'), '2026-10-15');
  });

  test('formata somente números com barras automáticas', () {
    const formatter = DataBrInputFormatter();
    final resultado = formatter.formatEditUpdate(
      const TextEditingValue(),
      const TextEditingValue(text: '15a102026'),
    );

    expect(resultado.text, '15/10/2026');
  });
}
