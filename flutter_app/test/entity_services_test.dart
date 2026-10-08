import 'package:flutter_test/flutter_test.dart';

import 'package:equip_control_app/models/equipamento.dart';
import 'package:equip_control_app/models/manutencao.dart';
import 'package:equip_control_app/repositories/equipamentos_repository.dart';
import 'package:equip_control_app/repositories/manutencoes_repository.dart';
import 'package:equip_control_app/services/api_client.dart';
import 'package:equip_control_app/services/equipamentos_service.dart';
import 'package:equip_control_app/services/manutencoes_service.dart';
import 'package:equip_control_app/services/sessao_service.dart';

import 'fake_auth_repository.dart';

Equipamento equipamento(int id) => Equipamento(
      id: id,
      nome: 'Equipamento $id',
      descricao: 'Descrição',
      dataAquisicao: '2025-01-01',
      patrimonio: 'PAT-$id',
      status: 'Ativo',
      categoria: const CategoriaResumo(id: 1, nome: 'Máquinas'),
      responsavel: const UsuarioResumo(id: 1, nome: 'Ana', cargo: 'gerente'),
    );

Manutencao manutencao(String status) => Manutencao(
      id: 1,
      idEquipamento: 1,
      equipamento: const EquipamentoResumo(
        id: 1,
        nome: 'Torno',
        patrimonio: 'PAT-1',
      ),
      idResponsavel: 1,
      responsavel: const UsuarioResumo(
        id: 1,
        nome: 'Ana',
        cargo: 'tecnico',
      ),
      descricao: 'Revisão',
      status: status,
      tipo: 'Preventiva',
      custo: 100,
      dataAbertura: '2025-01-01',
      dataConclusao: status == 'Concluída' ? '2025-01-02' : null,
    );

class FakeEquipamentosRepository implements EquipamentosRepository {
  List<Equipamento> dados = [equipamento(1)];
  String? buscaRecebida;
  int? categoriaRecebida;
  String? statusRecebido;

  @override
  Future<List<Equipamento>> listar({
    String? busca,
    int? idCategoria,
    String? status,
  }) async {
    buscaRecebida = busca;
    categoriaRecebida = idCategoria;
    statusRecebido = status;
    return dados;
  }

  @override
  Future<Equipamento> criar(EquipamentoInput dados) async {
    final criado = equipamento(2);
    this.dados = [...this.dados, criado];
    return criado;
  }

  @override
  Future<Equipamento> atualizar(int id, EquipamentoInput dados) async {
    final atualizado = equipamento(id);
    this.dados =
        this.dados.map((item) => item.id == id ? atualizado : item).toList();
    return atualizado;
  }

  @override
  Future<void> excluir(int id) async {
    dados = dados.where((item) => item.id != id).toList();
  }
}

class FakeManutencoesRepository implements ManutencoesRepository {
  List<Manutencao> dados = [manutencao('Pendente')];

  @override
  Future<List<Manutencao>> listar({
    int? idEquipamento,
    String? tipo,
    String? status,
  }) async =>
      dados;

  @override
  Future<Manutencao> criar(ManutencaoInput dados) async {
    final criada = manutencao('Pendente');
    this.dados = [...this.dados, criada];
    return criada;
  }

  @override
  Future<Manutencao> atualizar(int id, ManutencaoInput dados) async {
    final atualizada = manutencao(dados.status);
    this.dados = [atualizada];
    return atualizada;
  }

  @override
  Future<Manutencao> encerrar(int id, String dataConclusao) async {
    final encerrada = manutencao('Concluída');
    dados = [encerrada];
    return encerrada;
  }

  @override
  Future<void> excluir(int id) async {
    dados = [];
  }
}

class ErroEquipamentosRepository extends FakeEquipamentosRepository {
  @override
  Future<List<Equipamento>> listar({
    String? busca,
    int? idCategoria,
    String? status,
  }) async {
    throw const ApiException('Token inválido', 401);
  }
}

void main() {
  test('service de equipamentos carrega, cria, altera e exclui', () async {
    final repository = FakeEquipamentosRepository();
    final sessao = SessaoService(FakeAuthRepository());
    final service = EquipamentosService(repository, sessao);

    await service.carregar(busca: 'torno', idCategoria: 1, status: 'Ativo');
    expect(service.itens, hasLength(1));
    expect(repository.buscaRecebida, 'torno');
    expect(repository.categoriaRecebida, 1);
    expect(repository.statusRecebido, 'Ativo');

    const input = EquipamentoInput(
      nome: 'Novo',
      descricao: 'Descrição',
      dataAquisicao: '2025-01-01',
      patrimonio: 'PAT-2',
      status: 'Ativo',
      idCategoria: 1,
    );
    expect(await service.criar(input), isTrue);
    expect(await service.atualizar(1, input), isTrue);
    expect(await service.excluir(1), isTrue);
    expect(service.erro, isNull);
  });

  test('service limpa a sessão quando a API rejeita o token', () async {
    final sessao = SessaoService(FakeAuthRepository());
    await sessao.entrar('teste@exemplo.com', 'senha123');
    final service = EquipamentosService(ErroEquipamentosRepository(), sessao);

    await service.carregar();

    expect(sessao.autenticada, isFalse);
    expect(service.erro, 'Token inválido');
  });

  test('service de manutenções atualiza e encerra uma ordem', () async {
    final service = ManutencoesService(
      FakeManutencoesRepository(),
      SessaoService(FakeAuthRepository()),
    );

    await service.carregar();
    expect(service.itens.single.status, 'Pendente');

    expect(
      await service.encerrar(1, '2025-01-02'),
      isTrue,
    );
    expect(service.itens.single.status, 'Concluída');
    expect(
      await service.excluir(1),
      isTrue,
    );
    expect(service.itens, isEmpty);
  });
}
