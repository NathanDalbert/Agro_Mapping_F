// lib/view_models/cart_view_model.dart
import 'dart:convert';

import 'package:collection/collection.dart'; // Importe o pacote
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  CartViewModel() {
    _loadCart();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('cart', cartJson);
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      final List<dynamic> decoded = jsonDecode(cartString);
      for (final itemJson in decoded) {
        final produto = Produto.fromJson(itemJson['produto']);
        _items.add(CartItem(
          produto: produto,
          quantity: itemJson['quantity'] ?? 1,
        ));
      }
      notifyListeners();
    }
  }

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
    notifyListeners();
    _saveCart();
  }

  // Remove um item completamente do carrinho
  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
    _saveCart();
  }

  // Aumenta a quantidade de um item
  void incrementQuantity(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
    _saveCart();
  }

  // Diminui a quantidade de um item (e remove se chegar a zero)
  void decrementQuantity(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      _items.remove(cartItem);
    }
    notifyListeners();
    _saveCart();
  }

  // Limpa o carrinho
  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
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
