import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/estoque.dart';
import 'dio_client.dart';

class EstoqueService {
  final Dio _dio = DioClient().dio;

  Future<List<Estoque>> getAllEstoque() async {
    try {
      final response = await _dio.get('/estoque/');
      List<dynamic> data = response.data;
      return data.map((json) => Estoque.fromJson(json)).toList();
    } on DioException catch (_) {
      throw Exception('Não foi possível carregar os estoques.');
    }
  }

  Future<bool> criarEstoque({
    required String produtoId,
    required int quantidadeDisponivel,
  }) async {
    try {
      await _dio.post(
        '/estoque?produtoId=$produtoId',
        data: jsonEncode({
          'produtoId': produtoId,
          'quantidadeDisponivel': quantidadeDisponivel,
        }),
      );
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> atualizarEstoque({
    required String estoqueId,
    required int quantidadeDisponivel,
  }) async {
    try {
      await _dio.put(
        '/estoque/$estoqueId',
        data: jsonEncode({
          'quantidadeDisponivel': quantidadeDisponivel,
        }),
      );
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deletarEstoque(String estoqueId) async {
    try {
      await _dio.delete('/estoque/$estoqueId');
      return true;
    } on DioException catch (_) {
      return false;
    }
  }
}
