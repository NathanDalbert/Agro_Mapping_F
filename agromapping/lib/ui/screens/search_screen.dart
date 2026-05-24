import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../utils/image_helper.dart';
import '../../utils/view_state.dart';
import '../../view_models/busca_view_model.dart';
import '../../view_models/home_view_model.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() => _query = value);
    if (value.trim().isEmpty) {
      context.read<BuscaViewModel>().limpar();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<BuscaViewModel>().buscar(value.trim());
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    context.read<BuscaViewModel>().limpar();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final buscaViewModel = context.watch<BuscaViewModel>();
    final homeViewModel = context.read<HomeViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Buscar'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _query.isEmpty
                ? _buildInitialContent(homeViewModel)
                : _buildResults(buscaViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: cardColor,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 16, color: textColor),
          decoration: InputDecoration(
            hintText: 'Buscar produtos, categorias...',
            hintStyle: const TextStyle(color: textLightColor, fontSize: 15),
            prefixIcon: const Icon(Icons.search, color: primaryColor, size: 24),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: subtitleColor, size: 20),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            filled: false,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialContent(HomeViewModel homeViewModel) {
    final categories = homeViewModel.categories.where((c) => c != 'Todos').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (categories.isNotEmpty) ...[
            const Text(
              'Categorias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                return ActionChip(
                  label: Text(cat),
                  onPressed: () {
                    _searchController.text = cat;
                    _onSearchChanged(cat);
                  },
                  backgroundColor: surfaceColor,
                  side: BorderSide(color: Colors.grey.shade200),
                  labelStyle: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
          ],
          _buildPopularSection(homeViewModel),
        ],
      ),
    );
  }

  Widget _buildPopularSection(HomeViewModel homeViewModel) {
    final produtos = homeViewModel.produtos;
    if (produtos.isEmpty) return const SizedBox.shrink();

    final recent = produtos.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Destaques',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final produto = recent[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(produto: produto),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: AppImage(
                        source: produto.imagem,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produto.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'R\$ ${produto.preco.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResults(BuscaViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Center(
          child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
        );
      case ViewState.error:
        return _buildErrorState(viewModel);
      case ViewState.success:
        if (viewModel.resultados.isEmpty) {
          return _buildEmptyState();
        }
        return _buildResultsList(viewModel.resultados);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildErrorState(BuscaViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: dangerColor),
          const SizedBox(height: 16),
          Text(viewModel.errorMessage ?? 'Erro na busca.',
              style: const TextStyle(color: subtitleColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<BuscaViewModel>().buscar(_query),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tentar novamente'),
          ),
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
            child: const Icon(Icons.search_off, size: 48, color: textLightColor),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar por "$_query" com outras palavras',
            style: const TextStyle(fontSize: 14, color: subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List resultados) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${resultados.length} resultado${resultados.length == 1 ? '' : 's'} para "$_query"',
            style: const TextStyle(
              fontSize: 13,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: resultados.length,
            itemBuilder: (context, index) {
              final produto = resultados[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(produto: produto),
                    ),
                  );
                },
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
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: AspectRatio(
                              aspectRatio: 1.2,
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
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produto.nome,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textColor,
                                  height: 1.3,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'R\$ ${produto.preco.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
