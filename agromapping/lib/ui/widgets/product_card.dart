import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/produto.dart';
import '../../utils/colors.dart';
import '../../utils/image_helper.dart';
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
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: AspectRatio(
            aspectRatio: 1.1,
            child: AppImage(
              source: produto.imagem,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              produto.categoria,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (produto.estoque != null && produto.estoque!.quantidadeDisponivel > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: successColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${produto.estoque!.quantidadeDisponivel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              produto.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            if (produto.descricao.isNotEmpty)
              Text(
                produto.descricao,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: subtitleColor,
                  height: 1.3,
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'R\$ ${produto.preco.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                    const Text(
                      'por unidade',
                      style: TextStyle(fontSize: 9, color: textLightColor),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    context.read<CartViewModel>().addItem(produto);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${produto.nome} adicionado ao carrinho!'),
                        backgroundColor: primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(12),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
