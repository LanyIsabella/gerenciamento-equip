enum CargoUsuario {
  administrador('administrador', 'Administrador'),
  gerente('gerente', 'Gerente'),
  tecnico('tecnico', 'Técnico'),
  visualizador('visualizador', 'Visualizador');

  final String valor;
  final String rotulo;

  const CargoUsuario(this.valor, this.rotulo);

  static CargoUsuario fromApi(String valor) {
    return values.firstWhere(
      (cargo) => cargo.valor == valor.toLowerCase(),
      orElse: () => CargoUsuario.visualizador,
    );
  }

  bool get podeGerenciarEquipamentos =>
      this == CargoUsuario.administrador || this == CargoUsuario.gerente;

  bool get podeGerenciarManutencoes =>
      this == CargoUsuario.administrador || this == CargoUsuario.tecnico;
}
