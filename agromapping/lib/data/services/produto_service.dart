import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/produto.dart';
import 'dio_client.dart';

class ProdutoService {
  final Dio _dio = DioClient().dio;

  Future<SharedPreferences> _getPrefs() async =>
      await SharedPreferences.getInstance();

  Future<Options> _getAuthOptions() async {
    final prefs = await _getPrefs();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<Produto>> getProdutos() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('/produto/', options: options);
      List<dynamic> data = response.data;
      return data.map((json) => Produto.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar produtos: $e');
      throw Exception('Não foi possível carregar os produtos.');
    }
  }

  Future<List<Produto>> getMyProducts() async {
    try {
      final prefs = await _getPrefs();
      final usuarioId = prefs.getString('usuarioId');
      if (usuarioId == null) {
        throw Exception('ID do utilizador não encontrado.');
      }

      final options = await _getAuthOptions();
      final response = await _dio.get('/produto/', options: options);
      List<dynamic> data = response.data;

      return data
          .map((json) => Produto.fromJson(json))
          .where((p) => p.usuarioId == usuarioId)
          .toList();
    } on DioException catch (e) {
      print('Erro ao buscar meus produtos: $e');
      throw Exception('Não foi possível carregar seus produtos.');
    }
  }

  Future<List<Produto>> buscarPorNome(String nome) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '/produto/buscarProdutoPorNome/nome/$nome',
        options: options,
      );
      List<dynamic> data = response.data;
      return data.map((json) => Produto.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar produtos por nome: $e');
      throw Exception('Não foi possível buscar os produtos.');
    }
  }

  Future<bool> createProduct({
    required String nome,
    required String categoria,
    required String descricao,
    required double preco,
    required String imagem,
  }) async {
    try {
      final prefs = await _getPrefs();
      final usuarioId = prefs.getString('usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final productData = {
        'nome': nome,
        'categoria': categoria,
        'descricao': descricao,
        'preco': preco,
        'imagem': imagem,
        'usuarioId': usuarioId,
      };

      final options = await _getAuthOptions();
      await _dio.post(
        '/produto?usuarioId=$usuarioId',
        data: jsonEncode(productData),
        options: options,
      );
      return true;
    } on DioException catch (e) {
      print('Erro ao criar produto: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> updateProduct({
    required String produtoId,
    required String nome,
    required String categoria,
    required String descricao,
    required double preco,
    required String imagem,
  }) async {
    try {
      final prefs = await _getPrefs();
      final usuarioId = prefs.getString('usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final productData = {
        'nome': nome,
        'categoria': categoria,
        'descricao': descricao,
        'preco': preco,
        'imagem': imagem,
        'usuarioId': usuarioId,
      };

      final options = await _getAuthOptions();
      await _dio.put(
        '/produto/$produtoId',
        data: jsonEncode(productData),
        options: options,
      );
      return true;
    } on DioException catch (e) {
      print('Erro ao atualizar produto: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> deleteProduct(String produtoId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete('/produto/$produtoId', options: options);
      return true;
    } on DioException catch (e) {
      print('Erro ao excluir produto: ${e.response?.data}');
      return false;
    }
  }
}
