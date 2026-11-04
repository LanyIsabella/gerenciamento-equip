class CategoriaResumo {
  final int id;
  final String nome;

  const CategoriaResumo({required this.id, required this.nome});
}

class UsuarioResumo {
  final int id;
  final String nome;
  final String cargo;

  const UsuarioResumo({
    required this.id,
    required this.nome,
    required this.cargo,
  });

  factory UsuarioResumo.fromJson(Map<String, dynamic> json) {
    return UsuarioResumo(
      id: json['id'] as int,
      nome: json['nome'] as String,
      cargo: json['cargo'] as String,
    );
  }
}

class Equipamento {
  final int id;
  final String nome;
  final String descricao;
  final String dataAquisicao;
  final String patrimonio;
  final String status;
  final CategoriaResumo categoria;
  final UsuarioResumo responsavel;

  const Equipamento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.dataAquisicao,
    required this.patrimonio,
    required this.status,
    required this.categoria,
    required this.responsavel,
  });
}

class EquipamentoInput {
  final String nome;
  final String descricao;
  final String dataAquisicao;
  final String patrimonio;
  final String status;
  final int idCategoria;
  final int? idResponsavel;

  const EquipamentoInput({
    required this.nome,
    required this.descricao,
    required this.dataAquisicao,
    required this.patrimonio,
    required this.status,
    required this.idCategoria,
    this.idResponsavel,
  });
}
