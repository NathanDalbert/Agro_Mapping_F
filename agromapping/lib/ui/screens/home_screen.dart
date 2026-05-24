import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../utils/view_state.dart';
import '../../view_models/home_view_model.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: cardColor,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'AgroMapping',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.search, color: textColor, size: 22),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(child: _buildContent(homeViewModel)),
        ],
      ),
    );
  }

  Widget _buildContent(HomeViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
                const SizedBox(height: 16),
                const Text('Carregando produtos...',
                    style: TextStyle(color: subtitleColor, fontSize: 14)),
              ],
            ),
          ),
        );
      case ViewState.error:
        return SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 56, color: dangerColor.withValues(alpha: 0.6)),
                const SizedBox(height: 16),
                const Text('Erro ao carregar produtos',
                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('${viewModel.errorMessage}',
                    style: const TextStyle(color: subtitleColor, fontSize: 13)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => viewModel.fetchProdutos(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Tentar novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      case ViewState.success:
        if (viewModel.produtos.isEmpty) {
          return SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store_outlined, size: 64, color: textLightColor),
                  const SizedBox(height: 16),
                  const Text('Nenhum produto disponivel',
                      style: TextStyle(fontSize: 16, color: subtitleColor, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(viewModel),
            const SizedBox(height: 8),
            _buildCategoryChips(viewModel),
            const SizedBox(height: 12),
            _buildProductGrid(viewModel),
            const SizedBox(height: 100),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeader(HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produtos Frescos',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${viewModel.produtos.length} produtos disponiveis',
            style: const TextStyle(fontSize: 14, color: subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(HomeViewModel viewModel) {
    final categories = viewModel.categories;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == viewModel.selectedCategory;
          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) => viewModel.setCategory(cat),
            backgroundColor: surfaceColor,
            selectedColor: primaryColor.withValues(alpha: 0.15),
            labelStyle: TextStyle(
              color: isSelected ? primaryColor : subtitleColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: viewModel.produtos.length,
        itemBuilder: (context, index) {
          final produto = viewModel.produtos[index];
          return ProductCard(
            produto: produto,
            onCardTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(produto: produto),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
