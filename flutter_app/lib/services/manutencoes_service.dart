import 'package:flutter/foundation.dart';

import '../models/manutencao.dart';
import '../repositories/manutencoes_repository.dart';
import 'api_client.dart';
import 'sessao_service.dart';

class ManutencoesService extends ChangeNotifier {
  final ManutencoesRepository repository;
  final SessaoService sessao;

  List<Manutencao> itens = [];
  String? erro;
  bool carregando = false;

  ManutencoesService(this.repository, this.sessao);

  Future<void> carregar({
    int? idEquipamento,
    String? tipo,
    String? status,
  }) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      itens = await repository.listar(
        idEquipamento: idEquipamento,
        tipo: tipo,
        status: status,
      );
    } on ApiException catch (exception) {
      await _tratarErro(exception);
    } catch (_) {
      erro = 'Não foi possível carregar as manutenções.';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> criar(ManutencaoInput dados) async {
    return _alterar(() async {
      final criada = await repository.criar(dados);
      itens = [...itens, criada];
    });
  }

  Future<bool> atualizar(int id, ManutencaoInput dados) async {
    return _alterar(() async {
      final atualizada = await repository.atualizar(id, dados);
      itens = itens.map((item) => item.id == id ? atualizada : item).toList();
    });
  }

  Future<bool> encerrar(int id, String dataConclusao) async {
    return _alterar(() async {
      final encerrada = await repository.encerrar(id, dataConclusao);
      itens = itens.map((item) => item.id == id ? encerrada : item).toList();
    });
  }

  Future<bool> excluir(int id) async {
    return _alterar(() async {
      await repository.excluir(id);
      itens = itens.where((item) => item.id != id).toList();
    });
  }

  Future<bool> _alterar(Future<void> Function() operacao) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      await operacao();
      return true;
    } on ApiException catch (exception) {
      await _tratarErro(exception);
      return false;
    } catch (_) {
      erro = 'Não foi possível concluir a operação.';
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> _tratarErro(ApiException exception) async {
    if (exception.statusCode == 401) {
      await sessao.sair();
    }
    erro = exception.message;
  }
}
