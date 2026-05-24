import 'package:flutter/material.dart';

import '../data/models/produto.dart';
import '../data/services/produto_service.dart';
import '../utils/view_state.dart';

class BuscaViewModel extends ChangeNotifier {
  final ProdutoService _produtoService = ProdutoService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Produto> _resultados = [];
  List<Produto> get resultados => _resultados;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> buscar(String termo) async {
    if (termo.trim().isEmpty) {
      _resultados = [];
      _state = ViewState.success;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      _resultados = await _produtoService.buscarPorNome(termo);
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  void limpar() {
    _resultados = [];
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
