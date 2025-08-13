// lib/view_models/my_products_view_model.dart
import 'package:flutter/material.dart';

import '../data/models/produto.dart';
import '../data/services/produto_service.dart';

enum ViewState { idle, loading, success, error }

class MyProductsViewModel extends ChangeNotifier {
  final ProdutoService _produtoService = ProdutoService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Produto> _products = [];
  List<Produto> get products => _products;

  MyProductsViewModel() {
    fetchMyProducts();
  }

  Future<void> fetchMyProducts() async {
    _state = ViewState.loading;
    notifyListeners();
    try {
      _products = await _produtoService.getMyProducts();
      _state = ViewState.success;
    } catch (e) {
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
