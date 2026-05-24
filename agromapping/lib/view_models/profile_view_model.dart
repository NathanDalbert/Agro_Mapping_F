// lib/view_models/profile_view_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/models/usuario.dart';
import '../data/services/user_service.dart';
import '../utils/view_state.dart';

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
    final storage = const FlutterSecureStorage();
    await storage.deleteAll();
    notifyListeners();
  }
}
