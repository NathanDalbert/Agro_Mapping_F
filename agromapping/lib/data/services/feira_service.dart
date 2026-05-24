import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feira.dart';
import 'dio_client.dart';

class FeiraService {
  final Dio _dio = DioClient().dio;

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<Feira>> getFeiras() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('/feiras', options: options);
      List<dynamic> data = response.data;
      return data.map((json) => Feira.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar feiras: $e');
      throw Exception('Não foi possível carregar as feiras.');
    }
  }

  Future<bool> criarFeira({
    required String nome,
    required String localizacao,
    required String dataFuncionamento,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final options = await _getAuthOptions();
      await _dio.post(
        '/feiras',
        data: jsonEncode({
          'nome': nome,
          'localizacao': localizacao,
          'dataFuncionamento': dataFuncionamento,
          'latitude': latitude,
          'longitude': longitude,
        }),
        options: options,
      );
      return true;
    } on DioException catch (e) {
      print('Erro ao criar feira: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> atualizarFeira({
    required String feiraId,
    required String nome,
    required String localizacao,
    required String dataFuncionamento,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final options = await _getAuthOptions();
      await _dio.put(
        '/feiras/$feiraId',
        data: jsonEncode({
          'nome': nome,
          'localizacao': localizacao,
          'dataFuncionamento': dataFuncionamento,
          'latitude': latitude,
          'longitude': longitude,
        }),
        options: options,
      );
      return true;
    } on DioException catch (e) {
      print('Erro ao atualizar feira: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> deletarFeira(String feiraId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete('/feiras/$feiraId', options: options);
      return true;
    } on DioException catch (e) {
      print('Erro ao excluir feira: ${e.response?.data}');
      return false;
    }
  }
}
