import 'package:flutter/material.dart';

import '../../data/models/produto.dart';
import '../../data/services/produto_service.dart';
import '../../utils/colors.dart';
import '../../utils/image_helper.dart';

class EditProductScreen extends StatefulWidget {
  final Produto produto;

  const EditProductScreen({super.key, required this.produto});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _precoController;
  late final TextEditingController _descricaoController;
  late String _imagem;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto.nome);
    _categoriaController = TextEditingController(text: widget.produto.categoria);
    _precoController = TextEditingController(text: widget.produto.preco.toStringAsFixed(2));
    _descricaoController = TextEditingController(text: widget.produto.descricao);
    _imagem = widget.produto.imagem;
  }

  Future<void> _pickImage() async {
    final base64 = await ImageHelper.pickImageAsBase64();
    if (base64 != null) {
      setState(() => _imagem = base64);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final service = ProdutoService();
      final success = await service.updateProduct(
        produtoId: widget.produto.id,
        nome: _nomeController.text,
        categoria: _categoriaController.text,
        descricao: _descricaoController.text,
        preco: double.tryParse(_precoController.text) ?? 0.0,
        imagem: _imagem,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Produto atualizado com sucesso!'
                : 'Falha ao atualizar produto.'),
            backgroundColor: success ? successColor : dangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
        if (success) Navigator.of(context).pop(true);
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Editar Produto')),
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
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Salvar Alterações',
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
            color: primaryColor,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppImage(
                source: _imagem,
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
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Toque para alterar a imagem',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
