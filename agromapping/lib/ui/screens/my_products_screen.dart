import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/view_state.dart';
import '../../utils/image_helper.dart';
import '../../view_models/my_products_view_model.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyProductsViewModel>();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Meus Produtos')),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyProductsViewModel viewModel) {
    if (viewModel.state == ViewState.loading) {
      return const Center(
          child: CircularProgressIndicator(color: primaryColor));
    }
    if (viewModel.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: dangerColor),
            const SizedBox(height: 16),
            const Text('Erro ao carregar seus produtos.',
                style: TextStyle(color: subtitleColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchMyProducts(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (viewModel.products.isEmpty) {
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
              child: const Icon(Icons.storefront_outlined,
                  size: 56, color: textLightColor),
            ),
            const SizedBox(height: 20),
            const Text(
              'Voce ainda nao cadastrou nenhum produto.',
              style: TextStyle(fontSize: 16, color: subtitleColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Produto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
        final product = viewModel.products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(produto: product),
                ),
              );
              if (result == true) viewModel.fetchMyProducts();
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppImage(
                      source: product.imagem,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.categoria,
                          style: const TextStyle(
                              fontSize: 12, color: subtitleColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'R\$ ${product.preco.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: dangerColor),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Excluir Produto'),
                          content: Text('Deseja excluir "${product.nome}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Excluir',
                                  style: TextStyle(color: dangerColor)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final success = await viewModel.deleteProduct(product.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Produto excluido!'
                                  : 'Erro ao excluir produto.'),
                              backgroundColor:
                                  success ? successColor : dangerColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                          if (success) viewModel.fetchMyProducts();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
