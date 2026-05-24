import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/estoque.dart';
import 'dio_client.dart';

class EstoqueService {
  final Dio _dio = DioClient().dio;

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<Estoque>> getAllEstoque() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('/estoque/', options: options);
      List<dynamic> data = response.data;
      return data.map((json) => Estoque.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar estoques: $e');
      throw Exception('Não foi possível carregar os estoques.');
    }
  }

  Future<bool> criarEstoque({
    required String produtoId,
    required int quantidadeDisponivel,
  }) async {
    try {
      final options = await _getAuthOptions();
      await _dio.post(
        '/estoque?produtoId=$produtoId',
        data: jsonEncode({
          'produtoId': produtoId,
          'quantidadeDisponivel': quantidadeDisponivel,
        }),
        options: options,
      );
      return true;
    } on DioException catch (e) {
      print('Erro ao criar estoque: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> atualizarEstoque({
    required String estoqueId,
    required int quantidadeDisponivel,
  }) async {
    try {
      final options = await _getAuthOptions();
      await _dio.put(
        '/estoque/$estoqueId',
        data: jsonEncode({
          'quantidadeDisponivel': quantidadeDisponivel,
        }),
        options: options,
      );
      return true;
    } on DioException catch (e) {
      print('Erro ao atualizar estoque: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> deletarEstoque(String estoqueId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete('/estoque/$estoqueId', options: options);
      return true;
    } on DioException catch (e) {
      print('Erro ao excluir estoque: ${e.response?.data}');
      return false;
    }
  }
}
