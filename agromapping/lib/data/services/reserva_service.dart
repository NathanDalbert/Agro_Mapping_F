import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/reserva.dart';
import 'dio_client.dart';

class ReservaService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Reserva> criarReserva({
    required String idProduto,
    required int quantidade,
  }) async {
    final usuarioId = await _storage.read(key: 'usuarioId');
    if (usuarioId == null) throw Exception('Utilizador não autenticado.');

    final response = await _dio.post('/reserva', data: {
      'idUsuario': usuarioId,
      'idProduto': idProduto,
      'quantidade': quantidade,
    });
    return Reserva.fromJson(response.data);
  }

  Future<List<Reserva>> getMinhasReservas() async {
    final usuarioId = await _storage.read(key: 'usuarioId');
    if (usuarioId == null) throw Exception('Utilizador não autenticado.');

    final response = await _dio.get('/reserva/usuario/$usuarioId');
    final list = response.data as List<dynamic>;
    return list.map((e) => Reserva.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Reserva>> getReservasVendedor() async {
    final response = await _dio.get('/reserva/meus-produtos');
    final list = response.data as List<dynamic>;
    return list.map((e) => Reserva.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cancelarReserva(String idReserva) async {
    await _dio.patch('/reserva/$idReserva/status', data: {'status': 'CANCELADA'});
  }

  Future<void> confirmarRetirada(String idReserva) async {
    await _dio.patch('/reserva/$idReserva/status', data: {'status': 'RETIRADA'});
  }
}
