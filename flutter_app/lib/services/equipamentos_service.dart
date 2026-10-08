import 'package:flutter/foundation.dart';

import '../models/equipamento.dart';
import '../repositories/equipamentos_repository.dart';
import 'api_client.dart';
import 'sessao_service.dart';

class EquipamentosService extends ChangeNotifier {
  final EquipamentosRepository repository;
  final SessaoService sessao;

  List<Equipamento> itens = [];
  String? erro;
  bool carregando = false;

  EquipamentosService(this.repository, this.sessao);

  Future<void> carregar({
    String? busca,
    int? idCategoria,
    String? status,
  }) async {
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      itens = await repository.listar(
        busca: busca,
        idCategoria: idCategoria,
        status: status,
      );
    } on ApiException catch (exception) {
      await _tratarErro(exception);
    } catch (_) {
      erro = 'Não foi possível carregar os equipamentos.';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> criar(EquipamentoInput dados) async {
    return _alterar(() async {
      final criado = await repository.criar(dados);
      itens = [...itens, criado];
    });
  }

  Future<bool> atualizar(int id, EquipamentoInput dados) async {
    return _alterar(() async {
      final atualizado = await repository.atualizar(id, dados);
      itens = itens.map((item) => item.id == id ? atualizado : item).toList();
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
