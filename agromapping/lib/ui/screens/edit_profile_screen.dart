import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/usuario.dart';
import '../../utils/colors.dart';
import '../../view_models/editar_perfil_view_model.dart';
import 'login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Usuario usuario;

  const EditProfileScreen({super.key, required this.usuario});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _emailController = TextEditingController(text: widget.usuario.email);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final viewModel = context.read<EditarPerfilViewModel>();
      final success = await viewModel.atualizarPerfil(
        nome: _nomeController.text,
        email: _emailController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Perfil atualizado com sucesso!'
                : 'Falha ao atualizar perfil.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _excluirConta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
            'Tem certeza? Esta ação é irreversível e todos os seus dados serão perdidos.'),
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
      setState(() => _isLoading = true);
      final viewModel = context.read<EditarPerfilViewModel>();
      final success = await viewModel.excluirConta();

      if (mounted) {
        if (success) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Falha ao excluir conta.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: Text(
                    widget.usuario.nome.isNotEmpty
                        ? widget.usuario.nome[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontSize: 40, color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obrigatório';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar Alterações',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _excluirConta,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Excluir Conta',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
