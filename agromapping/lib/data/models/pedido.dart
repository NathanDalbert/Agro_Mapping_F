import 'item_pedido.dart';

class Pedido {
  final String id;
  final String dataPedido;
  final double valorTotal;
  final List<ItemPedido> itens;

  Pedido({
    required this.id,
    required this.dataPedido,
    required this.valorTotal,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['idPedido'] ?? '',
      dataPedido: json['dataPedido'] ?? '',
      valorTotal: (json['valorTotal'] as num).toDouble(),
      itens: (json['itens'] as List<dynamic>?)
              ?.map((e) => ItemPedido.fromJson(e))
              .toList() ??
          [],
    );
  }
}
