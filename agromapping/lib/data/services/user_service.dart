// lib/data/services/user_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import 'dio_client.dart';

class UserService {
  final Dio _dio = DioClient().dio;

  // Busca os dados do utilizador logado usando o ID guardado
  Future<Usuario> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getString('usuarioId');

      if (token == null || usuarioId == null) {
        throw Exception('Utilizador não autenticado.');
      }

      final response = await _dio.get(
        '/usuario/$usuarioId', // Endpoint para buscar por ID
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Usuario.fromJson(response.data);
    } on DioException catch (e) {
      print('Erro ao buscar perfil do utilizador: $e');
      throw Exception('Não foi possível carregar os dados do perfil.');
    }
  }
}
