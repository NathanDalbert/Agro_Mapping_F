import 'package:flutter/material.dart';

import '../data/services/user_service.dart';
import '../utils/view_state.dart';

class EditarPerfilViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> atualizarPerfil({
    required String nome,
    required String email,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await _userService.updateUser(
      nome: nome,
      email: email,
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> excluirConta() async {
    _isLoading = true;
    notifyListeners();

    final success = await _userService.deleteUser();

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
