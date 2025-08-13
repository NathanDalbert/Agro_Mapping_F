// lib/data/models/cart_item.dart
import 'produto.dart';

class CartItem {
  final Produto produto;
  int quantity;

  CartItem({required this.produto, this.quantity = 1});

  // Calcula o subtotal para este item
  double get subtotal => produto.preco * quantity;
}
