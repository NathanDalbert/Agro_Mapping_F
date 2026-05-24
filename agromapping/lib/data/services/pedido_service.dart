import 'dart:convert';

import 'package:agromapping/data/services/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/pedido.dart';

class PedidoService {
  final Dio _dio = DioClient().dio;

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<bool> criarPedido(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getString('usuarioId');

      if (token == null || usuarioId == null) {
        throw Exception('Utilizador não autenticado.');
      }

      final pedidoData = {
        'dataPedido': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'idUsuario': usuarioId,
        'itens': items
            .map((item) => {
                  'idProduto': item.produto.id,
                  'quantidade': item.quantity,
                  'idUsuario': usuarioId,
                })
            .toList(),
      };

      await _dio.post(
        '/pedido',
        data: jsonEncode(pedidoData),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return true;
    } on DioException catch (e) {
      print('Erro ao criar pedido: $e');
      return false;
    }
  }

  Future<List<Pedido>> getPedidosByUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getString('usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final options = await _getAuthOptions();
      final response = await _dio.get(
        '/pedido/usuario/$usuarioId',
        options: options,
      );

      List<dynamic> data = response.data;
      return data.map((json) => Pedido.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar pedidos: $e');
      throw Exception('Não foi possível carregar seus pedidos.');
    }
  }

  Future<bool> cancelarPedido(String pedidoId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete('/pedido/$pedidoId', options: options);
      return true;
    } on DioException catch (e) {
      print('Erro ao cancelar pedido: ${e.response?.data}');
      return false;
    }
  }
}
