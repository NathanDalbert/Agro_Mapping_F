import 'package:flutter/material.dart';

import '../data/models/estoque.dart';
import '../data/models/produto.dart';
import '../data/services/estoque_service.dart';
import '../data/services/produto_service.dart';
import '../utils/view_state.dart';

class EstoqueViewModel extends ChangeNotifier {
  final EstoqueService _estoqueService = EstoqueService();
  final ProdutoService _produtoService = ProdutoService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Estoque> _estoques = [];
  List<Estoque> get estoques => _estoques;

  List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  EstoqueViewModel() {
    fetchData();
  }

  Future<void> fetchData() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _estoqueService.getAllEstoque(),
        _produtoService.getProdutos(),
      ]);
      _estoques = results[0] as List<Estoque>;
      _produtos = results[1] as List<Produto>;
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  String getProductName(String produtoId) {
    final produto = _produtos.where((p) => p.id == produtoId).firstOrNull;
    return produto?.nome ?? 'Produto ${produtoId.substring(0, 8)}...';
  }

  String? getProductImage(String produtoId) {
    final produto = _produtos.where((p) => p.id == produtoId).firstOrNull;
    return produto?.imagem;
  }

  Future<bool> atualizarQuantidade(String estoqueId, int novaQuantidade) async {
    _isLoading = true;
    notifyListeners();

    final success = await _estoqueService.atualizarEstoque(
      estoqueId: estoqueId,
      quantidadeDisponivel: novaQuantidade,
    );

    if (success) {
      final index = _estoques.indexWhere((e) => e.idEstoque == estoqueId);
      if (index != -1) {
        _estoques[index] = Estoque(
          idEstoque: _estoques[index].idEstoque,
          produtoId: _estoques[index].produtoId,
          quantidadeDisponivel: novaQuantidade,
        );
      }
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> criarEstoque(String produtoId, int quantidade) async {
    _isLoading = true;
    notifyListeners();

    final success = await _estoqueService.criarEstoque(
      produtoId: produtoId,
      quantidadeDisponivel: quantidade,
    );

    if (success) {
      await fetchData();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
