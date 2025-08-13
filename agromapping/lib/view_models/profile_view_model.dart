// lib/view_models/profile_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/usuario.dart';
import '../data/services/user_service.dart';

enum ViewState { idle, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  Usuario? _user;
  Usuario? get user => _user;

  ProfileViewModel() {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _user = await _userService.getUserProfile();
      _state = ViewState.success;
    } catch (e) {
      _state = ViewState.error;
    }
    notifyListeners();
  }

  // Função de Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpa todos os dados guardados
  }
}
