import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../utils/image_helper.dart';
import '../widgets/product_form_view_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precoController = TextEditingController();
  final _descricaoController = TextEditingController();
  String? _imagemBase64;

  Future<void> _pickImage() async {
    final base64 = await ImageHelper.pickImageAsBase64();
    if (base64 != null) {
      setState(() => _imagemBase64 = base64);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_imagemBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione uma imagem para o produto.'),
            backgroundColor: warningColor,
          ),
        );
        return;
      }

      final viewModel = context.read<ProductFormViewModel>();
      final success = await viewModel.createProduct(
        nome: _nomeController.text,
        categoria: _categoriaController.text,
        descricao: _descricaoController.text,
        preco: double.tryParse(_precoController.text) ?? 0.0,
        imagem: _imagemBase64!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Produto cadastrado com sucesso!'
                : 'Falha ao cadastrar produto.'),
            backgroundColor: success ? successColor : dangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
        if (success) Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductFormViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Cadastrar Produto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  prefixIcon: Icon(Icons.eco_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço (ex: 10.50)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obrigatório';
                  if (double.tryParse(v) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: viewModel.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Cadastrar Produto',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _imagemBase64 != null ? primaryColor : Colors.grey.shade300,
            width: _imagemBase64 != null ? 2 : 1,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: _imagemBase64 != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AppImage(
                      source: _imagemBase64!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_outlined,
                        size: 40, color: primaryColor),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toque para selecionar uma imagem',
                    style: TextStyle(color: subtitleColor, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPG ou PNG, máximo 800x800',
                    style: TextStyle(color: textLightColor, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
