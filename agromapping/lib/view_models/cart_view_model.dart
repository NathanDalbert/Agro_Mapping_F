// lib/view_models/cart_view_model.dart
import 'package:collection/collection.dart'; // Importe o pacote
import 'package:flutter/material.dart';

import '../data/models/cart_item.dart';
import '../data/models/produto.dart';
import '../data/services/pedido_service.dart';

class CartViewModel extends ChangeNotifier {
  final PedidoService _pedidoService = PedidoService();
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Calcula o número total de itens no carrinho
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Calcula o preço total do carrinho
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  // Adiciona um produto ao carrinho
  void addItem(Produto produto) {
    // Verifica se o item já existe no carrinho
    final existingItem =
        _items.firstWhereOrNull((item) => item.produto.id == produto.id);

    if (existingItem != null) {
      existingItem.quantity++;
    } else {
      _items.add(CartItem(produto: produto));
    }
    notifyListeners(); // Notifica a UI para se atualizar
  }

  // Remove um item completamente do carrinho
  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  // Aumenta a quantidade de um item
  void incrementQuantity(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  // Diminui a quantidade de um item (e remove se chegar a zero)
  void decrementQuantity(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      _items.remove(cartItem);
    }
    notifyListeners();
  }

  // Limpa o carrinho
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Finaliza o pedido
  Future<bool> checkout() async {
    if (_items.isEmpty) return false;

    final success = await _pedidoService.criarPedido(_items);
    if (success) {
      clearCart();
    }
    return success;
  }
}
