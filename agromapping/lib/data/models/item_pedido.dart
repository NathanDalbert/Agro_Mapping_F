import 'produto.dart';

class ItemPedido {
  final String id;
  final Produto produto;
  final int quantidade;
  final double valorTotalItem;

  ItemPedido({
    required this.id,
    required this.produto,
    required this.quantidade,
    required this.valorTotalItem,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      id: json['itemPedido']?.toString() ?? '',
      produto: Produto.fromJson(json['produto'] as Map<String, dynamic>),
      quantidade: json['quantidade'] as int? ?? 0,
      valorTotalItem: (json['valorTotalItem'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
