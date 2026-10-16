import 'package:flutter_test/flutter_test.dart';

import 'package:equip_control_app/models/cargo_usuario.dart';

void main() {
  test('converte os quatro cargos retornados pela API', () {
    expect(CargoUsuario.fromApi('administrador'), CargoUsuario.administrador);
    expect(CargoUsuario.fromApi('gerente'), CargoUsuario.gerente);
    expect(CargoUsuario.fromApi('tecnico'), CargoUsuario.tecnico);
    expect(CargoUsuario.fromApi('visualizador'), CargoUsuario.visualizador);
  });

  test('aplica as permissões de cada cargo', () {
    expect(CargoUsuario.administrador.podeGerenciarEquipamentos, isTrue);
    expect(CargoUsuario.administrador.podeGerenciarManutencoes, isTrue);

    expect(CargoUsuario.gerente.podeGerenciarEquipamentos, isTrue);
    expect(CargoUsuario.gerente.podeGerenciarManutencoes, isFalse);

    expect(CargoUsuario.tecnico.podeGerenciarEquipamentos, isFalse);
    expect(CargoUsuario.tecnico.podeGerenciarManutencoes, isTrue);

    expect(CargoUsuario.visualizador.podeGerenciarEquipamentos, isFalse);
    expect(CargoUsuario.visualizador.podeGerenciarManutencoes, isFalse);
  });
}
