// lib/view_models/home_view_model.dart
import 'package:flutter/material.dart';

import '../data/models/produto.dart';
import '../data/services/produto_service.dart';

// Enum para um controlo de estado mais limpo
enum ViewState { idle, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final ProdutoService _produtoService = ProdutoService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // O construtor é chamado uma vez, e inicia a busca de produtos.
  HomeViewModel() {
    fetchProdutos();
  }

  // Função que chama o serviço para buscar os dados na API
  Future<void> fetchProdutos() async {
    _state = ViewState.loading;
    notifyListeners(); // Avisa a UI para mostrar o loading

    try {
      _produtos = await _produtoService.getProdutos();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }

    // Avisa a UI novamente, agora com os dados ou o erro.
    notifyListeners();
  }
}
