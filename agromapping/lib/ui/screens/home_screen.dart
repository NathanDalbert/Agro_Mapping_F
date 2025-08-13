// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';

// Esta é uma tela temporária para onde o utilizador será redirecionado
// após o login. Vamos construí-la a seguir.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Login bem-sucedido!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
