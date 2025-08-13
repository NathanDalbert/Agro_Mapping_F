// lib/ui/widgets/cart_item_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/cart_item.dart';
import '../../utils/colors.dart';
import '../../view_models/cart_view_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.read<CartViewModel>();

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Imagem do Produto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.produto.imagem,
                  width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            // Detalhes do Produto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.produto.nome,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 4),
                  const Text('Por Fazenda Verde',
                      style: TextStyle(color: subtitleColor)),
                  const SizedBox(height: 8),
                  Text('R\$ ${item.produto.preco.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          color: primaryColor,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Ações (Remover e Quantidade)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => cartViewModel.removeItem(item),
                ),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => cartViewModel.decrementQuantity(item)),
                    Text('${item.quantity}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => cartViewModel.incrementQuantity(item)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
