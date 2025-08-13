// lib/ui/screens/add_product_screen.dart
import 'package:agromapping/ui/widgets/product_form_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nomeController = TextEditingController();
    final _categoriaController = TextEditingController();
    final _precoController = TextEditingController();
    final _descricaoController = TextEditingController();
    final _imagemController = TextEditingController();

    final viewModel = context.watch<ProductFormViewModel>();

    void _submitForm() async {
      if (_formKey.currentState?.validate() ?? false) {
        final success = await viewModel.createProduct(
          nome: _nomeController.text,
          categoria: _categoriaController.text,
          descricao: _descricaoController.text,
          preco: double.tryParse(_precoController.text) ?? 0.0,
          imagem: _imagemController.text,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Produto cadastrado com sucesso!'
                  : 'Falha ao cadastrar produto.'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          if (success) {
            Navigator.of(context).pop();
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Cadastrar Novo Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration:
                    const InputDecoration(labelText: 'Preço (ex: 10.50)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obrigatório';
                  if (double.tryParse(v) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imagemController,
                decoration: const InputDecoration(labelText: 'URL da Imagem'),
                keyboardType: TextInputType.url,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: viewModel.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar Produto',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
