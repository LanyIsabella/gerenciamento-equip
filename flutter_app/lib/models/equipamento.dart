class CategoriaResumo {
  final int id;
  final String nome;

  const CategoriaResumo({required this.id, required this.nome});

  factory CategoriaResumo.fromJson(Map<String, dynamic> json) {
    return CategoriaResumo(
      id: json['id'] as int,
      nome: json['nome'] as String,
    );
  }
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

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    return Equipamento(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      dataAquisicao: json['data_aquisicao'] as String,
      patrimonio: json['patrimonio'] as String,
      status: json['status'] as String,
      categoria: CategoriaResumo.fromJson(
        json['categoria'] as Map<String, dynamic>,
      ),
      responsavel: UsuarioResumo.fromJson(
        json['responsavel'] as Map<String, dynamic>,
      ),
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'data_aquisicao': dataAquisicao,
      'patrimonio': patrimonio,
      'status': status,
      'id_categoria': idCategoria,
      if (idResponsavel != null) 'id_responsavel': idResponsavel,
    };
  }
}
