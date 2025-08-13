// lib/view_models/product_form_view_model.dart
import 'package:agromapping/data/services/produto_service.dart';
import 'package:flutter/material.dart';

class ProductFormViewModel extends ChangeNotifier {
  final ProdutoService _produtoService = ProdutoService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> createProduct({
    required String nome,
    required String categoria,
    required String descricao,
    required double preco,
    required String imagem,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await _produtoService.createProduct(
      nome: nome,
      categoria: categoria,
      descricao: descricao,
      preco: preco,
      imagem: imagem,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
