import 'cargo_usuario.dart';

class Usuario {
  final int id;
  final String nome;
  final String email;
  final CargoUsuario cargo;
  final bool ativo;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
    required this.ativo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      cargo: CargoUsuario.fromApi(json['cargo'] as String),
      ativo: json['ativo'] as bool? ?? true,
    );
  }
}
