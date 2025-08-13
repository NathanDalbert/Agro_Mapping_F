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
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();
    final dataNascimentoController = TextEditingController();
    final telefoneController = TextEditingController();

    // Ouve as mudanças no ViewModel para reconstruir a UI
    final registerViewModel = context.watch<RegisterViewModel>();

    // Função para abrir o seletor de data
    Future<void> selectDate() async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        // Formata a data para o padrão que o backend espera (yyyy-MM-dd)
        dataNascimentoController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      }
    }

    // Função para submeter o formulário de registo
    void doRegister() async {
      if (formKey.currentState?.validate() ?? false) {
        final result = await registerViewModel.register(
          nome: nomeController.text,
          email: emailController.text,
          senha: senhaController.text,
          dataDeNascimento: dataNascimentoController.text,
          telefone: telefoneController.text,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Ocorreu um erro.'),
              backgroundColor: result['success'] ? Colors.green : Colors.red,
            ),
          );
          if (result['success']) {
            Navigator.of(context).pop(); // Volta para a tela de login
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campos de Nome, Email, Senha, Data de Nascimento
                  TextFormField(
                      controller: nomeController,
                      decoration:
                          const InputDecoration(labelText: 'Nome Completo'),
                      validator: (v) =>
                          v!.isEmpty ? 'Campo obrigatório' : null),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty || !v.contains('@')
                          ? 'Email inválido'
                          : null),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: senhaController,
                      obscureText: !registerViewModel.isPasswordVisible,
                      decoration: InputDecoration(
                          labelText: 'Senha',
                          suffixIcon: IconButton(
                              icon: Icon(registerViewModel.isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed:
                                  registerViewModel.togglePasswordVisibility)),
                      validator: (v) =>
                          v!.length < 6 ? 'Mínimo de 6 caracteres' : null),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: dataNascimentoController,
                      decoration: const InputDecoration(
                          labelText: 'Data de Nascimento',
                          prefixIcon: Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: selectDate,
                      validator: (v) =>
                          v!.isEmpty ? 'Campo obrigatório' : null),
                  const SizedBox(height: 24),

                  // Seleção de Tipo de Conta
                  const Text('Tipo de Conta',
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  RoleSelectionCard(
                      title: 'Quero comprar',
                      subtitle: 'Comprar produtos frescos',
                      icon: Icons.person_outline,
                      value: 'USER',
                      groupValue: registerViewModel.userRole,
                      onChanged: (val) => registerViewModel.setUserRole(val)),
                  const SizedBox(height: 12),
                  RoleSelectionCard(
                      title: 'Quero vender',
                      subtitle: 'Vender meus produtos',
                      icon: Icons.storefront_outlined,
                      value: 'SELLER',
                      groupValue: registerViewModel.userRole,
                      onChanged: (val) => registerViewModel.setUserRole(val)),

                  // AQUI ESTÁ A LÓGICA VISUAL CONDICIONAL
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: registerViewModel.userRole == 'SELLER'
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: TextFormField(
                              controller: telefoneController,
                              decoration: const InputDecoration(
                                  labelText: 'Telefone de Contato',
                                  prefixIcon: Icon(Icons.phone_outlined)),
                              keyboardType: TextInputType.phone,
                              validator: (v) =>
                                  (registerViewModel.userRole == 'SELLER' &&
                                          v!.isEmpty)
                                      ? 'Campo obrigatório para vendedores'
                                      : null,
                            ),
                          )
                        : const SizedBox
                            .shrink(), // Widget vazio se não for vendedor
                  ),
                  const SizedBox(height: 24),

                  // Botão de Registar
                  ElevatedButton(
                    onPressed: registerViewModel.isLoading ? null : doRegister,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: registerViewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registar',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
