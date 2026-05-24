import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../utils/view_state.dart';
import '../../view_models/gerenciar_feiras_view_model.dart';

class GerenciarFeirasScreen extends StatelessWidget {
  const GerenciarFeirasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GerenciarFeirasViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Gerenciar Feiras')),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCriarFeiraDialog(context, viewModel),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GerenciarFeirasViewModel viewModel) {
    if (viewModel.state == ViewState.loading && viewModel.feiras.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: primaryColor));
    }

    if (viewModel.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage ?? 'Erro ao carregar feiras.',
                style: const TextStyle(color: subtitleColor)),
          ],
        ),
      );
    }

    if (viewModel.feiras.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: subtitleColor),
            SizedBox(height: 16),
            Text('Nenhuma feira cadastrada.',
                style: TextStyle(fontSize: 16, color: subtitleColor)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.feiras.length,
      itemBuilder: (context, index) {
        final feira = viewModel.feiras[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          color: cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: const Icon(Icons.storefront_outlined,
                  color: primaryColor),
            ),
            title: Text(
              feira.nome,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: subtitleColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(feira.localizacao,
                          style: const TextStyle(color: subtitleColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: subtitleColor),
                    const SizedBox(width: 4),
                    Text(
                      'Data: ${feira.dataFuncionamento.toIso8601String().split('T').first}',
                      style: const TextStyle(color: subtitleColor),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Excluir Feira'),
                    content:
                        Text('Deseja realmente excluir "${feira.nome}"?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Excluir',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  final success =
                      await viewModel.deletarFeira(feira.idFeira);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Feira excluída!'
                            : 'Erro ao excluir feira.'),
                        backgroundColor:
                            success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showCriarFeiraDialog(
      BuildContext context, GerenciarFeirasViewModel viewModel) {
    final nomeController = TextEditingController();
    final localizacaoController = TextEditingController();
    final dataController = TextEditingController();
    final latController = TextEditingController(text: '-23.5505');
    final lngController = TextEditingController(text: '-46.6333');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Feira'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration:
                      const InputDecoration(labelText: 'Nome da Feira'),
                  validator: (v) =>
                      v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: localizacaoController,
                  decoration:
                      const InputDecoration(labelText: 'Localização'),
                  validator: (v) =>
                      v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dataController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Funcionamento',
                    hintText: 'AAAA-MM-DD',
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: latController,
                        decoration:
                            const InputDecoration(labelText: 'Latitude'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: lngController,
                        decoration:
                            const InputDecoration(labelText: 'Longitude'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx);
                final success = await viewModel.criarFeira(
                  nome: nomeController.text,
                  localizacao: localizacaoController.text,
                  dataFuncionamento: dataController.text,
                  latitude:
                      double.tryParse(latController.text) ?? -23.5505,
                  longitude:
                      double.tryParse(lngController.text) ?? -46.6333,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Feira criada com sucesso!'
                          : 'Erro ao criar feira.'),
                      backgroundColor:
                          success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Criar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
