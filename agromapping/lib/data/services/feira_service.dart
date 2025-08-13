// lib/data/services/feira_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feira.dart';
import 'dio_client.dart';

class FeiraService {
  final Dio _dio = DioClient().dio;

  Future<List<Feira>> getFeiras() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token não encontrado.');

      final response = await _dio.get(
        '/feiras',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      List<dynamic> data = response.data;
      return data.map((json) => Feira.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar feiras: $e');
      throw Exception('Não foi possível carregar as feiras.');
    }
  }
}
