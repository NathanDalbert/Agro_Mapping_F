import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/contato.dart';
import 'dio_client.dart';

class ContatoService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Contato> createContato(String telefone) async {
    try {
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final response = await _dio.post(
        '/contato?usuarioId=$usuarioId',
        data: jsonEncode({'telefone': telefone, 'usuarioId': usuarioId}),
      );

      return Contato.fromJson(response.data);
    } on DioException catch (_) {
      throw Exception('Falha ao criar contato.');
    }
  }

  Future<List<Contato>> getMeusContatos() async {
    try {
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final response = await _dio.get('/usuario/$usuarioId');

      final List<dynamic> contatosJson = response.data['contatos'] ?? [];
      return contatosJson.map((json) => Contato.fromJson(json)).toList();
    } on DioException catch (_) {
      throw Exception('Falha ao buscar contatos.');
    }
  }

  Future<Contato> updateContato(String contatoId, String novoTelefone) async {
    try {
      final response = await _dio.put(
        '/contato/$contatoId',
        data: jsonEncode({'telefone': novoTelefone}),
      );
      return Contato.fromJson(response.data);
    } on DioException catch (_) {
      throw Exception('Falha ao atualizar contato.');
    }
  }

  Future<void> deleteContato(String contatoId) async {
    try {
      await _dio.delete('/contato/$contatoId');
    } on DioException catch (_) {
      throw Exception('Falha ao apagar contato.');
    }
  }
}
