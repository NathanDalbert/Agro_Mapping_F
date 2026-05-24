import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../utils/image_helper.dart';
import '../../utils/view_state.dart';
import '../../view_models/estoque_view_model.dart';

class GerenciarEstoqueScreen extends StatelessWidget {
  const GerenciarEstoqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EstoqueViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Gerenciar Estoque')),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(EstoqueViewModel viewModel) {
    if (viewModel.state == ViewState.loading && viewModel.estoques.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: primaryColor));
    }

    if (viewModel.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: dangerColor),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage ?? 'Erro ao carregar estoques.',
                style: const TextStyle(color: subtitleColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchData(),
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

    if (viewModel.estoques.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: subtitleColor),
            SizedBox(height: 16),
            Text('Nenhum estoque cadastrado.',
                style: TextStyle(fontSize: 16, color: subtitleColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.estoques.length,
      itemBuilder: (context, index) {
        final estoque = viewModel.estoques[index];
        final nome = viewModel.getProductName(estoque.produtoId);
        final imagem = viewModel.getProductImage(estoque.produtoId);

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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppImage(
                    source: imagem ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Disponivel: ${estoque.quantidadeDisponivel} un.',
                            style: const TextStyle(
                                color: subtitleColor, fontSize: 13),
                          ),
                          _EstoqueBadge(
                              quantidade: estoque.quantidadeDisponivel),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditDialog(
                            context,
                            viewModel,
                            estoque.idEstoque,
                            estoque.quantidadeDisponivel,
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Editar Quantidade'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor, width: 1),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
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
    );
  }

  void _showEditDialog(
    BuildContext context,
    EstoqueViewModel viewModel,
    String estoqueId,
    int quantidadeAtual,
  ) {
    final controller =
        TextEditingController(text: quantidadeAtual.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Atualizar Estoque'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantidade disponivel',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final novaQtd = int.tryParse(controller.text);
              if (novaQtd != null) {
                Navigator.pop(ctx);
                final success = await viewModel.atualizarQuantidade(
                    estoqueId, novaQtd);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Estoque atualizado!'
                          : 'Erro ao atualizar estoque.'),
                      backgroundColor:
                          success ? successColor : dangerColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(12),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _EstoqueBadge extends StatelessWidget {
  final int quantidade;

  const _EstoqueBadge({required this.quantidade});

  @override
  Widget build(BuildContext context) {
    final color = quantidade == 0
        ? dangerColor
        : quantidade < 10
            ? warningColor
            : successColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        quantidade == 0 ? 'Esgotado' : '$quantidade un.',
        style: TextStyle(
            color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
