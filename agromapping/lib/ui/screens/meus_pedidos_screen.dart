import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../view_models/pedidos_view_model.dart';
import 'detalhe_pedido_screen.dart';

class MeusPedidosScreen extends StatelessWidget {
  const MeusPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PedidosViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Meus Pedidos')),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, PedidosViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Center(
            child: CircularProgressIndicator(color: primaryColor));
      case ViewState.error:
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage ?? 'Erro ao carregar pedidos.',
                style: const TextStyle(color: subtitleColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchPedidos(),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Tentar novamente',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ));
      case ViewState.success:
        if (viewModel.pedidos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: subtitleColor),
                SizedBox(height: 16),
                Text('Você ainda não fez nenhum pedido.',
                    style: TextStyle(fontSize: 16, color: subtitleColor)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.pedidos.length,
          itemBuilder: (context, index) {
            final pedido = viewModel.pedidos[index];
            return _PedidoCard(
              pedido: pedido,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DetalhePedidoScreen(pedido: pedido),
                  ),
                );
              },
              onCancel: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancelar Pedido'),
                    content: Text(
                        'Deseja realmente cancelar o pedido ${pedido.id.substring(0, 8)}...?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Não')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sim',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  final success = await viewModel.cancelarPedido(pedido.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Pedido cancelado com sucesso!'
                            : 'Erro ao cancelar pedido.'),
                        backgroundColor:
                            success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _PedidoCard extends StatelessWidget {
  final dynamic pedido;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _PedidoCard({
    required this.pedido,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${pedido.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  Chip(
                    label: Text('${pedido.itens.length} itens'),
                    backgroundColor: primaryColor.withOpacity(0.1),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: subtitleColor),
                  const SizedBox(width: 6),
                  Text(
                    pedido.dataPedido,
                    style: const TextStyle(color: subtitleColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ ${pedido.valorTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
