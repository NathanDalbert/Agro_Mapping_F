// lib/data/services/contato_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contato.dart';
import 'dio_client.dart';

class ContatoService {
  final Dio _dio = DioClient().dio;

  // Helper para obter as SharedPreferences
  Future<SharedPreferences> _getPrefs() async =>
      await SharedPreferences.getInstance();

  // Helper para obter o token e o ID do utilizador
  Future<Map<String, String>> _getAuthData() async {
    final prefs = await _getPrefs();
    final token = prefs.getString('token');
    final usuarioId = prefs.getString('usuarioId');
    if (token == null || usuarioId == null) {
      throw Exception('Utilizador não autenticado.');
    }
    return {'token': token, 'usuarioId': usuarioId};
  }

  // Helper para obter as opções de autenticação para as chamadas Dio
  Future<Options> _getAuthOptions() async {
    final authData = await _getAuthData();
    return Options(headers: {'Authorization': 'Bearer ${authData['token']}'});
  }

  // --- MÉTODOS CRUD ---

  // 1. CRIAR um novo contato (POST /contato)
  Future<Contato> createContato(String telefone) async {
    try {
      final authData = await _getAuthData();
      final usuarioId = authData['usuarioId'];
      final options = await _getAuthOptions();

      final response = await _dio.post(
        '/contato?usuarioId=$usuarioId', // Endpoint com query param
        data: jsonEncode({'telefone': telefone, 'usuarioId': usuarioId}),
        options: options,
      );

      return Contato.fromJson(response.data);
    } on DioException catch (e) {
      print('Erro ao criar contato: ${e.response?.data}');
      throw Exception('Falha ao criar contato.');
    }
  }

  // 2. LER os contatos do utilizador (GET /usuario/{id}/contatos no backend)
  //    Como não há um endpoint direto, vamos buscar o perfil do utilizador.
  Future<List<Contato>> getMeusContatos() async {
    try {
      final authData = await _getAuthData();
      final usuarioId = authData['usuarioId'];
      final options = await _getAuthOptions();

      // O seu backend retorna os contatos dentro do objeto do utilizador
      final response = await _dio.get('/usuario/$usuarioId', options: options);

      // Extrai a lista de contatos da resposta
      final List<dynamic> contatosJson = response.data['contatos'] ?? [];
      return contatosJson.map((json) => Contato.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar contatos: ${e.response?.data}');
      throw Exception('Falha ao buscar contatos.');
    }
  }

  // 3. ATUALIZAR um contato existente (PUT /contato/{id})
  Future<Contato> updateContato(String contatoId, String novoTelefone) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put(
        '/contato/$contatoId',
        data: jsonEncode({'telefone': novoTelefone}),
        options: options,
      );
      return Contato.fromJson(response.data);
    } on DioException catch (e) {
      print('Erro ao atualizar contato: ${e.response?.data}');
      throw Exception('Falha ao atualizar contato.');
    }
  }

  // 4. APAGAR um contato (DELETE /contato/{id})
  Future<void> deleteContato(String contatoId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete('/contato/$contatoId', options: options);
    } on DioException catch (e) {
      print('Erro ao apagar contato: ${e.response?.data}');
      throw Exception('Falha ao apagar contato.');
    }
  }
}
