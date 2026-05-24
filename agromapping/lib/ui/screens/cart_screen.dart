import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../view_models/cart_view_model.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CartViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Carrinho ${viewModel.items.isEmpty ? "" : "(${viewModel.itemCount})"}'),
      ),
      body: viewModel.items.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: viewModel.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(viewModel.items[index].produto.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: dangerColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          viewModel.removeItem(viewModel.items[index]);
                        },
                        child: CartItemCard(item: viewModel.items[index]),
                      );
                    },
                  ),
                ),
                _buildSummary(context, viewModel),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 56, color: textLightColor),
          ),
          const SizedBox(height: 20),
          const Text(
            'Seu carrinho esta vazio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione produtos frescos dos\nprodutores locais',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CartViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal',
                    style: TextStyle(fontSize: 14, color: subtitleColor)),
                Text('R\$ ${viewModel.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Frete',
                    style: TextStyle(fontSize: 14, color: subtitleColor)),
                Text('Gratis',
                    style: TextStyle(fontSize: 14, color: successColor, fontWeight: FontWeight.w600)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: dividerColor, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    )),
                Text(
                  'R\$ ${viewModel.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await viewModel.checkout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Pedido realizado com sucesso!'
                            : 'Falha ao realizar o pedido.'),
                        backgroundColor: success ? successColor : dangerColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Finalizar Pedido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
