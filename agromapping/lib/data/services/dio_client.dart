// lib/data/services/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        // CORREÇÃO: A baseUrl não deve conter o prefixo /api
        baseUrl: "http://localhost:8090",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );
  }
}
