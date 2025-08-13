// lib/ui/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../view_models/login_view_model.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final loginViewModel = context.watch<LoginViewModel>();

    void doLogin() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Preencha todos os campos.'),
              backgroundColor: Colors.orange),
        );
        return;
      }
      final result = await loginViewModel.login(
          emailController.text, passwordController.text);
      if (!context.mounted) return;
      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Ocorreu um erro.'),
              backgroundColor: Colors.red),
        );
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: primaryColor.withOpacity(0.9),
                      child: const Text('A',
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    const Text('AgroMapping',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 8),
                    const Text('Conecte-se aos produtores locais',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: subtitleColor)),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !loginViewModel.isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(loginViewModel.isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: loginViewModel.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    loginViewModel.isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: primaryColor))
                        : ElevatedButton(
                            onPressed: doLogin,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            child: const Text('Entrar',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen())),
                      child: const Text('Não tem conta? Registre-se aqui',
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
