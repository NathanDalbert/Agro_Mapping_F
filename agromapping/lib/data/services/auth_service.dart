// lib/data/services/auth_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String senha) async {
    print('--- Tentativa de Login ---');
    print('Email: $email');
    try {
      final response = await _dio.post(
        '/api/login', // O prefixo /api fica aqui
        data: jsonEncode({'email': email, 'senha': senha}),
      );

      final Map<String, dynamic> responseData = response.data;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseData['token']);
      await prefs.setString('usuarioId', responseData['usuarioId']);

      print('Login bem-sucedido. Token guardado.');
      return {'success': true};
    } on DioException catch (e) {
      print('!!!!!! ERRO NO LOGIN !!!!!!');
      print('URL da Requisição: ${e.requestOptions.uri}');
      print('Status Code: ${e.response?.statusCode}');
      print('Resposta do Servidor: ${e.response?.data}');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      String errorMessage =
          e.response?.data['message'] ?? 'Email ou senha inválidos.';
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
    print('--- Tentativa de Registo ---');
    print('Role selecionada: $userRole');
    print('Telefone fornecido: $telefone');

    try {
      // --- CHAMADA 1: REGISTAR UTILIZADOR ---
      final userRequestBody = {
        'nome': nome,
        'email': email,
        'senha': senha,
        'dataDeNascimento': dataDeNascimento,
        'userRole': userRole,
      };

      print(
          'Enviando dados do utilizador para /api/register: ${jsonEncode(userRequestBody)}');

      final userResponse = await _dio.post(
        '/api/register', // O prefixo /api fica aqui
        data: jsonEncode(userRequestBody),
      );

      print('Utilizador criado com sucesso. Resposta: ${userResponse.data}');
      final String newUserId = userResponse.data['usuarioId'];

      // --- CHAMADA 2: REGISTAR CONTATO (APENAS SE FOR VENDEDOR) ---
      if (userRole == 'SELLER' && telefone != null && telefone.isNotEmpty) {
        final contactRequestBody = {
          'telefone': telefone,
          'usuarioId': newUserId,
        };

        print(
            'Enviando dados do contato para /contato: ${jsonEncode(contactRequestBody)}');

        await _dio.post(
          '/contato?usuarioId=$newUserId',
          data: jsonEncode(contactRequestBody),
        );
        print('Contato criado com sucesso.');
      }

      return {'success': true, 'message': 'Registo bem-sucedido!'};
    } on DioException catch (e) {
      print('!!!!!! ERRO NO REGISTO !!!!!!');
      print('URL da Requisição: ${e.requestOptions.uri}');
      print('Status Code: ${e.response?.statusCode}');
      print('Resposta do Servidor: ${e.response?.data}');
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

      String errorMessage =
          e.response?.data['message'] ?? 'Erro ao registar utilizador.';
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('!!!!!! ERRO INESPERADO NO REGISTO !!!!!!');
      print(e.toString());
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      return {'success': false, 'message': 'Ocorreu um erro inesperado.'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Dados locais (token/userId) limpos.');
  }
}
