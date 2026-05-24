import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../view_models/register_view_model.dart';
import '../widgets/role_selection_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _telefoneController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _dataNascimentoController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dataNascimentoController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _doRegister(RegisterViewModel registerViewModel) async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await registerViewModel.register(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        dataDeNascimento: _dataNascimentoController.text,
        telefone: _telefoneController.text,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Ocorreu um erro.'),
            backgroundColor: result['success'] ? successColor : dangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
        if (result['success']) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerViewModel = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crie sua conta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Preencha os dados abaixo para comecar',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatorio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@')
                      ? 'Email invalido'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: !registerViewModel.isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(registerViewModel.isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: registerViewModel.togglePasswordVisibility,
                    ),
                  ),
                  validator: (v) =>
                      v!.length < 6 ? 'Minimo de 6 caracteres' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dataNascimentoController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (v) => v!.isEmpty ? 'Campo obrigatorio' : null,
                ),
                const SizedBox(height: 28),
                const Text('Tipo de Conta',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 12),
                RoleSelectionCard(
                  title: 'Quero comprar',
                  subtitle: 'Comprar produtos frescos',
                  icon: Icons.person_outline,
                  value: 'USER',
                  groupValue: registerViewModel.userRole,
                  onChanged: (val) => registerViewModel.setUserRole(val),
                ),
                const SizedBox(height: 12),
                RoleSelectionCard(
                  title: 'Quero vender',
                  subtitle: 'Vender meus produtos',
                  icon: Icons.storefront_outlined,
                  value: 'SELLER',
                  groupValue: registerViewModel.userRole,
                  onChanged: (val) => registerViewModel.setUserRole(val),
                ),
                const SizedBox(height: 28),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: registerViewModel.userRole == 'SELLER'
                      ? Column(
                          children: [
                            TextFormField(
                              controller: _telefoneController,
                              decoration: const InputDecoration(
                                labelText: 'Telefone de Contato',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (v) =>
                                  (registerViewModel.userRole == 'SELLER' &&
                                          v!.isEmpty)
                                      ? 'Campo obrigatorio para vendedores'
                                      : null,
                            ),
                            const SizedBox(height: 28),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                ElevatedButton(
                  onPressed: registerViewModel.isLoading ? null : () => _doRegister(registerViewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: registerViewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Criar Conta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
