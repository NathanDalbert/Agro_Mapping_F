import 'package:flutter/material.dart';

import '../data/models/produto.dart';
import '../data/services/produto_service.dart';
import '../utils/view_state.dart';

class HomeViewModel extends ChangeNotifier {
  final ProdutoService _produtoService = ProdutoService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Produto> _produtos = [];
  List<Produto> get produtos => _filteredProdutos;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'Todos';
  String get selectedCategory => _selectedCategory;

  List<Produto> get _filteredProdutos {
    if (_selectedCategory == 'Todos') return _produtos;
    return _produtos.where((p) => p.categoria == _selectedCategory).toList();
  }

  List<String> get categories {
    final cats = <String>{'Todos'};
    for (final p in _produtos) {
      cats.add(p.categoria);
    }
    return cats.toList();
  }

  HomeViewModel() {
    fetchProdutos();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchProdutos() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _produtos = await _produtoService.getProdutos();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }

    notifyListeners();
  }
}
