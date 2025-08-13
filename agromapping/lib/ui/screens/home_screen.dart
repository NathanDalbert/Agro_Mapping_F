// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../view_models/home_view_model.dart';
import '../widgets/product_card.dart';
// import 'product_detail_screen.dart'; // Futura tela de detalhes

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: primaryColor,
            child: Text('A',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        title: const Text('AgroMapping',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: textColor, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildProductList(homeViewModel),
    );
  }

  Widget _buildProductList(HomeViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Center(
            child: CircularProgressIndicator(color: primaryColor));
      case ViewState.error:
        return Center(
            child:
                Text('Erro ao carregar produtos: ${viewModel.errorMessage}'));
      case ViewState.success:
        if (viewModel.produtos.isEmpty) {
          return const Center(child: Text('Nenhum produto encontrado.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: viewModel.produtos.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeader();
            }
            final produto = viewModel.produtos[index - 1];
            return ProductCard(
              produto: produto,
              onCardTap: () {
                // Navegação para a futura tela de detalhes
              },
              // O parâmetro onAddToCartTap foi removido daqui, pois a lógica
              // agora está dentro do próprio ProductCard.
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produtos Frescos',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
          ),
          SizedBox(height: 4),
          Text(
            'Direto dos produtores locais para sua mesa',
            style: TextStyle(fontSize: 16, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
