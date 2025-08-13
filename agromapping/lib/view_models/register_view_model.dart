// lib/view_models/register_view_model.dart
import 'package:flutter/material.dart';

import '../data/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userRole = 'USER'; // O valor inicial é 'USER'
  String get userRole => _userRole;

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Este método é chamado quando o utilizador clica nos cartões de seleção
  void setUserRole(String role) {
    _userRole = role;
    notifyListeners(); // Avisa a tela para se reconstruir e mostrar/esconder o campo de contato
  }

  Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String senha,
    required String dataDeNascimento,
    String? telefone,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      nome: nome,
      email: email,
      senha: senha,
      dataDeNascimento: dataDeNascimento,
      userRole: _userRole,
      telefone: telefone,
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
