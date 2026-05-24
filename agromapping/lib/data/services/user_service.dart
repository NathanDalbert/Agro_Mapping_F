import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import 'dio_client.dart';

class UserService {
  final Dio _dio = DioClient().dio;

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Usuario> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getString('usuarioId');

      if (token == null || usuarioId == null) {
        throw Exception('Utilizador não autenticado.');
      }

      final response = await _dio.get(
        '/usuario/$usuarioId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Usuario.fromJson(response.data);
    } on DioException catch (e) {
      print('Erro ao buscar perfil do utilizador: $e');
      throw Exception('Não foi possível carregar os dados do perfil.');
    }
  }

  Future<bool> updateUser({
    required String nome,
    required String email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getString('usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final options = await _getAuthOptions();
      await _dio.put(
        '/usuario/$usuarioId',
        data: jsonEncode({
          'nome': nome,
          'email': email,
        }),
        options: options,
      );
      return true;
    } on DioException catch (e) {
      print('Erro ao atualizar perfil: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getString('usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final options = await _getAuthOptions();
      await _dio.delete('/usuario/$usuarioId', options: options);

      await prefs.clear();
      return true;
    } on DioException catch (e) {
      print('Erro ao excluir conta: ${e.response?.data}');
      return false;
    }
  }
}
