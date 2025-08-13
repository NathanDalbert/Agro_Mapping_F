// lib/ui/screens/meus_contatos_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/contato.dart';
import '../../utils/colors.dart';
import '../../view_models/contatos_view_model.dart';

class MeusContatosScreen extends StatelessWidget {
  const MeusContatosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ContatosViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Meus Contatos'),
      ),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, viewModel),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ContatosViewModel viewModel) {
    if (viewModel.state == ViewState.loading) {
      return const Center(
          child: CircularProgressIndicator(color: primaryColor));
    }
    if (viewModel.state == ViewState.error) {
      return Center(
          child: Text('Erro ao carregar contatos: ${viewModel.errorMessage}'));
    }
    if (viewModel.contatos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum contato cadastrado.\nToque em "+" para adicionar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: subtitleColor),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: viewModel.contatos.length,
      itemBuilder: (context, index) {
        final contato = viewModel.contatos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: const Icon(Icons.phone_outlined, color: primaryColor),
            title: Text(contato.telefone,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                  onPressed: () =>
                      _showAddEditDialog(context, viewModel, contato: contato),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () =>
                      _showDeleteConfirmation(context, viewModel, contato),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditDialog(BuildContext context, ContatosViewModel viewModel,
      {Contato? contato}) {
    final telefoneController =
        TextEditingController(text: contato?.telefone ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(contato == null ? 'Adicionar Contato' : 'Editar Contato'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'Número de Telefone'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  bool success;
                  if (contato == null) {
                    success =
                        await viewModel.addContato(telefoneController.text);
                  } else {
                    success = await viewModel.updateContato(
                        contato.id, telefoneController.text);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Operação bem-sucedida!'
                            : 'Falha na operação.'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, ContatosViewModel viewModel, Contato contato) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: Text(
                  'Tem certeza de que deseja apagar o contato ${contato.telefone}?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    viewModel.deleteContato(contato.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apagar'),
                ),
              ],
            ));
  }
}
