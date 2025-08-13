// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/screens/login_screen.dart';
import 'view_models/login_view_model.dart';
import 'view_models/register_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
      ],
      child: MaterialApp(
        title: 'AgroMapping',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins', // Pode usar Poppins ou Roboto
          scaffoldBackgroundColor: Colors.grey[200],
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
