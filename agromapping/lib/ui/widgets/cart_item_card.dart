import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/cart_item.dart';
import '../../utils/colors.dart';
import '../../utils/image_helper.dart';
import '../../view_models/cart_view_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.read<CartViewModel>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppImage(
              source: item.produto.imagem,
              width: 80,
              height: 80,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.produto.categoria,
                  style: const TextStyle(fontSize: 12, color: subtitleColor),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${(item.produto.preco * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                    _buildQuantitySelector(cartViewModel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(CartViewModel cartViewModel) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => cartViewModel.decrementQuantity(item),
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => cartViewModel.incrementQuantity(item),
          ),
        ],
      ),
    );
  }
}
