import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/produto.dart';
import 'dio_client.dart';

class ProdutoService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<List<Produto>> getProdutos() async {
    try {
      final response = await _dio.get('/produto/');
      List<dynamic> data = response.data;
      return data.map((json) => Produto.fromJson(json)).toList();
    } on DioException catch (_) {
      throw Exception('Não foi possível carregar os produtos.');
    }
  }

  Future<List<Produto>> getMyProducts() async {
    try {
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) {
        throw Exception('ID do utilizador não encontrado.');
      }

      final response = await _dio.get('/produto/');
      List<dynamic> data = response.data;

      return data
          .map((json) => Produto.fromJson(json))
          .where((p) => p.usuarioId == usuarioId)
          .toList();
    } on DioException catch (_) {
      throw Exception('Não foi possível carregar seus produtos.');
    }
  }

  Future<List<Produto>> buscarPorNome(String nome) async {
    try {
      final response = await _dio.get('/produto/buscarProdutoPorNome/nome/$nome');
      List<dynamic> data = response.data;
      return data.map((json) => Produto.fromJson(json)).toList();
    } on DioException catch (_) {
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
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final productData = {
        'nome': nome,
        'categoria': categoria,
        'descricao': descricao,
        'preco': preco,
        'imagem': imagem,
        'usuarioId': usuarioId,
      };

      await _dio.post(
        '/produto?usuarioId=$usuarioId',
        data: jsonEncode(productData),
      );
      return true;
    } on DioException catch (_) {
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
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final productData = {
        'nome': nome,
        'categoria': categoria,
        'descricao': descricao,
        'preco': preco,
        'imagem': imagem,
        'usuarioId': usuarioId,
      };

      await _dio.put(
        '/produto/$produtoId',
        data: jsonEncode(productData),
      );
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> deleteProduct(String produtoId) async {
    try {
      await _dio.delete('/produto/$produtoId');
      return true;
    } on DioException catch (_) {
      return false;
    }
  }
}
