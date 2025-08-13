// lib/data/services/pedido_service.dart
import 'dart:convert';

import 'package:agromapping/data/services/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';

class PedidoService {
  final Dio _dio = DioClient().dio;

  // Usa o PedidoRequestDTO do backend
  Future<bool> criarPedido(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getString('usuarioId');

      if (token == null || usuarioId == null) {
        throw Exception('Utilizador não autenticado.');
      }

      // Constrói o corpo da requisição (payload)
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

      return true; // Sucesso
    } on DioException catch (e) {
      print('Erro ao criar pedido: $e');
      return false; // Falha
    }
  }
}
