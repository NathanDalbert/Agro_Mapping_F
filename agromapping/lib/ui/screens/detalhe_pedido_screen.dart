import 'package:flutter/material.dart';

import '../../data/models/pedido.dart';
import '../../utils/colors.dart';
import '../../utils/image_helper.dart';

class DetalhePedidoScreen extends StatelessWidget {
  final Pedido pedido;

  const DetalhePedidoScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Detalhes do Pedido')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            const Text(
              'Itens do Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...pedido.itens.map((item) => _buildItemCard(item)),
            const SizedBox(height: 16),
            _buildTotalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${pedido.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Chip(
                  label: Text(pedido.itens.length == 1
                      ? '1 item'
                      : '${pedido.itens.length} itens'),
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: subtitleColor),
                const SizedBox(width: 6),
                Text(
                  'Data: ${pedido.dataPedido}',
                  style: const TextStyle(color: subtitleColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppImage(
              source: item.produto.imagem,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.produto.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qtd: ${item.quantidade}x R\$ ${item.produto.preco.toStringAsFixed(2)}',
                  style: const TextStyle(color: subtitleColor),
                ),
              ],
            ),
          ),
          Text(
            'R\$ ${item.valorTotalItem.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total do Pedido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            'R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
