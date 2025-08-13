// lib/ui/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/produto.dart';
import '../../utils/colors.dart';
import '../../view_models/cart_view_model.dart';

class ProductCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback onCardTap;

  const ProductCard({
    super.key,
    required this.produto,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos 'read' aqui porque a ação de adicionar ao carrinho não precisa
    // que este widget seja reconstruído quando o carrinho muda.
    final cartViewModel = context.read<CartViewModel>();

    return GestureDetector(
      onTap: onCardTap,
      child: Card(
        elevation: 1,
        color: cardColor,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem com tags sobrepostas
            Stack(
              children: [
                Image.network(
                  produto.imagem,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 180,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Tag "Novo" (dado estático por enquanto)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Chip(
                    label: const Text(
                      'Novo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                  ),
                ),
                // Rating (dado estático por enquanto)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Chip(
                    label: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            // Informações do produto
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // O nome do vendedor viria do `produto.usuario.nome`
                  const Text(
                    'Por Fazenda Verde', // TODO: Substituir pelo nome do vendedor real
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'R\$ ${produto.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {
                          // Ação de adicionar ao carrinho
                          cartViewModel.addItem(produto);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${produto.nome} adicionado ao carrinho!'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: primaryColor,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        style: IconButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
