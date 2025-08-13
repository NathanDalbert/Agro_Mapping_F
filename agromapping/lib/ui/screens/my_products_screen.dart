// lib/ui/screens/my_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../view_models/my_products_view_model.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyProductsViewModel>();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Meus Produtos'),
      ),
      body: _buildBody(viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(MyProductsViewModel viewModel) {
    if (viewModel.state == ViewState.loading) {
      return const Center(child: CircularProgressIndicator(color: primaryColor));
    }
    if (viewModel.state == ViewState.error) {
      return const Center(child: Text('Erro ao carregar seus produtos.'));
    }
    if (viewModel.products.isEmpty) {
      return const Center(child: Text('Você ainda não cadastrou nenhum produto.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
        final product = viewModel.products[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(product.imagem)),
            title: Text(product.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('R\$ ${product.preco.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, color: primaryColor), onPressed: () {}),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {}),
              ],
            ),
          ),
        );
      },
    );
  }
}
