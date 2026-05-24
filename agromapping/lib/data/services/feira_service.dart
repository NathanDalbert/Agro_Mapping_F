import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/feira.dart';
import 'dio_client.dart';

class FeiraService {
  final Dio _dio = DioClient().dio;

  Future<List<Feira>> getFeiras() async {
    try {
      final response = await _dio.get('/feiras');
      List<dynamic> data = response.data;
      return data.map((json) => Feira.fromJson(json)).toList();
    } on DioException catch (_) {
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
      await _dio.post(
        '/feiras',
        data: jsonEncode({
          'nome': nome,
          'localizacao': localizacao,
          'dataFuncionamento': dataFuncionamento,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      return true;
    } on DioException catch (_) {
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
      await _dio.put(
        '/feiras/$feiraId',
        data: jsonEncode({
          'nome': nome,
          'localizacao': localizacao,
          'dataFuncionamento': dataFuncionamento,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deletarFeira(String feiraId) async {
    try {
      await _dio.delete('/feiras/$feiraId');
      return true;
    } on DioException catch (_) {
      return false;
    }
  }
}
