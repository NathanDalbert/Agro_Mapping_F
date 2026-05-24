import 'dart:convert';

import 'package:agromapping/data/services/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../models/cart_item.dart';
import '../models/pedido.dart';

class PedidoService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> criarPedido(List<CartItem> items) async {
    try {
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

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

      await _dio.post('/pedido', data: jsonEncode(pedidoData));
      return true;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<List<Pedido>> getPedidosByUsuario() async {
    try {
      final usuarioId = await _secureStorage.read(key: 'usuarioId');
      if (usuarioId == null) throw Exception('Utilizador não autenticado.');

      final response = await _dio.get('/pedido/usuario/$usuarioId');
      List<dynamic> data = response.data;
      return data.map((json) => Pedido.fromJson(json)).toList();
    } on DioException catch (_) {
      throw Exception('Não foi possível carregar seus pedidos.');
    }
  }

  Future<bool> cancelarPedido(String pedidoId) async {
    try {
      await _dio.patch('/pedido/$pedidoId/status', data: {'status': 'CANCELADO'});
      return true;
    } on DioException catch (_) {
      return false;
    }
  }
}
