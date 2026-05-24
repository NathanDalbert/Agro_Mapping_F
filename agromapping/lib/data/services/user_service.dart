import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/usuario.dart';
import 'dio_client.dart';

class UserService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Usuario> getUserProfile() async {
    try {
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) {
        throw Exception('Utilizador não autenticado.');
      }

      final response = await _dio.get('/usuario/$usuarioId');
      return Usuario.fromJson(response.data);
    } on DioException catch (_) {
      throw Exception('Não foi possível carregar os dados do perfil.');
    }
  }

  Future<bool> updateUser({
    required String nome,
    required String email,
  }) async {
    try {
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      await _dio.put(
        '/usuario/$usuarioId',
        data: jsonEncode({
          'nome': nome,
          'email': email,
        }),
      );
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deleteUser() async {
    try {
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      await _dio.delete('/usuario/$usuarioId');
      await _secureStorage.deleteAll();
      return true;
    } on DioException catch (_) {
      return false;
    }
  }
}
