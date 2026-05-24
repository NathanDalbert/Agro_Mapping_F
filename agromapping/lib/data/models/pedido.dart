import 'item_pedido.dart';

class Pedido {
  final String id;
  final String dataPedido;
  final double valorTotal;
  final List<ItemPedido> itens;
  final String? status;

  Pedido({
    required this.id,
    required this.dataPedido,
    required this.valorTotal,
    required this.itens,
    this.status,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['idPedido']?.toString() ?? '',
      dataPedido: json['dataPedido']?.toString() ?? '',
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0.0,
      itens: (json['itens'] as List<dynamic>?)
              ?.map((e) => ItemPedido.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status']?.toString(),
    );
  }
}
