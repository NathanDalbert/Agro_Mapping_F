// lib/data/services/auth_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await _dio.post(
        '/login',
        data: jsonEncode({'email': email, 'senha': senha}),
      );

      final Map<String, dynamic> responseData = response.data;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseData['token']);
      await prefs.setString('usuarioId', responseData['usuarioId']);

      return {'success': true};
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['body'] ?? 'Email ou senha inválidos.';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Ocorreu um erro inesperado.'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String senha,
    required String dataDeNascimento,
    required String userRole,
  }) async {
    try {
      await _dio.post(
        '/register',
        data: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
          'dataDeNascimento': dataDeNascimento,
          'userRole': userRole,
        }),
      );
      return {'success': true, 'message': 'Registo bem-sucedido!'};
    } on DioException catch (e) {
      String errorMessage = e.response?.data is String
          ? e.response?.data
          : e.response?.data['message'] ?? 'Erro ao registar.';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Ocorreu um erro inesperado.'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuarioId');
  }
}
