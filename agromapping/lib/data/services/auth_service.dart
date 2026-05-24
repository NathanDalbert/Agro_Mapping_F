import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await _dio.post(
        '/api/login',
        data: jsonEncode({'email': email, 'senha': senha}),
      );

      final Map<String, dynamic> responseData = response.data;
      await _secureStorage.write(key: 'token', value: responseData['token']);
      await _secureStorage.write(key: 'usuarioId', value: responseData['usuarioId']);

      return {'success': true};
    } on DioException catch (e) {
      String errorMessage = 'Email ou senha inválidos.';
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        errorMessage = data['message'].toString();
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<Map<String, dynamic>> register({
    required String nome,
    required String email,
    required String senha,
    required String dataDeNascimento,
    required String userRole,
    String? telefone,
  }) async {
    try {
      final userRequestBody = {
        'nome': nome,
        'email': email,
        'senha': senha,
        'dataDeNascimento': dataDeNascimento,
        'userRole': userRole,
      };

      final userResponse = await _dio.post(
        '/api/register',
        data: jsonEncode(userRequestBody),
      );

      final String newUserId = userResponse.data['usuarioId'];

      if (userRole == 'SELLER' && telefone != null && telefone.isNotEmpty) {
        final contactRequestBody = {
          'telefone': telefone,
          'usuarioId': newUserId,
        };

        await _dio.post(
          '/contato?usuarioId=$newUserId',
          data: jsonEncode(contactRequestBody),
        );
      }

      return {'success': true, 'message': 'Registo bem-sucedido!'};
    } on DioException catch (e) {
      String errorMessage =
          e.response?.data['message'] ?? 'Erro ao registar utilizador.';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Ocorreu um erro inesperado.'};
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
}
