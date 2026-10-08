import 'equipamento.dart';

class EquipamentoResumo {
  final int id;
  final String nome;
  final String patrimonio;

  const EquipamentoResumo({
    required this.id,
    required this.nome,
    required this.patrimonio,
  });

  factory EquipamentoResumo.fromJson(Map<String, dynamic> json) {
    return EquipamentoResumo(
      id: json['id'] as int,
      nome: json['nome'] as String,
      patrimonio: json['patrimonio'] as String,
    );
  }
}

class Manutencao {
  final int id;
  final int idEquipamento;
  final EquipamentoResumo equipamento;
  final int idResponsavel;
  final UsuarioResumo responsavel;
  final String descricao;
  final String status;
  final String tipo;
  final double custo;
  final String dataAbertura;
  final String? dataConclusao;

  const Manutencao({
    required this.id,
    required this.idEquipamento,
    required this.equipamento,
    required this.idResponsavel,
    required this.responsavel,
    required this.descricao,
    required this.status,
    required this.tipo,
    required this.custo,
    required this.dataAbertura,
    required this.dataConclusao,
  });

  factory Manutencao.fromJson(Map<String, dynamic> json) {
    return Manutencao(
      id: json['id'] as int,
      idEquipamento: json['id_equipamento'] as int,
      equipamento: EquipamentoResumo.fromJson(
        json['equipamento'] as Map<String, dynamic>,
      ),
      idResponsavel: json['id_responsavel'] as int,
      responsavel: UsuarioResumo.fromJson(
        json['responsavel'] as Map<String, dynamic>,
      ),
      descricao: json['descricao'] as String,
      status: json['status'] as String,
      tipo: json['tipo'] as String,
      custo: (json['custo'] as num).toDouble(),
      dataAbertura: json['data_abertura'] as String,
      dataConclusao: json['data_conclusao'] as String?,
    );
  }
}

class ManutencaoInput {
  final int idEquipamento;
  final String descricao;
  final String status;
  final String tipo;
  final double custo;
  final String dataAbertura;
  final String? dataConclusao;
  final int? idResponsavel;

  const ManutencaoInput({
    required this.idEquipamento,
    required this.descricao,
    required this.status,
    required this.tipo,
    required this.custo,
    required this.dataAbertura,
    this.dataConclusao,
    this.idResponsavel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_equipamento': idEquipamento,
      'descricao': descricao,
      'status': status,
      'tipo': tipo,
      'custo': custo,
      'data_abertura': dataAbertura,
      if (dataConclusao != null) 'data_conclusao': dataConclusao,
      if (idResponsavel != null) 'id_responsavel': idResponsavel,
    };
  }
}
