// lib/ui/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../view_models/register_view_model.dart';
import '../widgets/role_selection_card.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nomeController = TextEditingController();
    final _emailController = TextEditingController();
    final _senhaController = TextEditingController();
    final _dataNascimentoController = TextEditingController();
    final registerViewModel = context.watch<RegisterViewModel>();

    Future<void> selectDate() async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        ),
      );
      if (picked != null) {
        _dataNascimentoController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    }

    void doRegister() async {
      if (_formKey.currentState?.validate() ?? false) {
        final result = await registerViewModel.register(
          nome: _nomeController.text,
          email: _emailController.text,
          senha: _senhaController.text,
          dataDeNascimento: _dataNascimentoController.text,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Ocorreu um erro.'),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );

        if (result['success']) {
          Navigator.of(context).pop();
        }
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryColor,
                  child: Text(
                    'A',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Criar Conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Junte-se à nossa comunidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nome Completo',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          hintText: 'Seu nome completo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'seu@email.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty || !v.contains('@')
                            ? 'Email inválido'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Senha',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: !registerViewModel.isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: '********',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              registerViewModel.isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                registerViewModel.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) =>
                            v!.length < 6 ? 'Mínimo de 6 caracteres' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Data de Nascimento',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _dataNascimentoController,
                        decoration: InputDecoration(
                          hintText: 'dd/mm/aaaa',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        readOnly: true,
                        onTap: selectDate,
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Tipo de Conta',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                registerViewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : ElevatedButton(
                        onPressed: doRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Registar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Já tem conta? Faça login aqui',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
