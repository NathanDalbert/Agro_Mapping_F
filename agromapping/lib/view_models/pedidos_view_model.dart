import 'package:flutter/material.dart';

import '../data/models/pedido.dart';
import '../data/services/pedido_service.dart';

enum ViewState { idle, loading, success, error }

class PedidosViewModel extends ChangeNotifier {
  final PedidoService _pedidoService = PedidoService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Pedido> _pedidos = [];
  List<Pedido> get pedidos => _pedidos;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PedidosViewModel() {
    fetchPedidos();
  }

  Future<void> fetchPedidos() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _pedidos = await _pedidoService.getPedidosByUsuario();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> cancelarPedido(String pedidoId) async {
    final success = await _pedidoService.cancelarPedido(pedidoId);
    if (success) {
      _pedidos.removeWhere((p) => p.id == pedidoId);
      notifyListeners();
    }
    return success;
  }
}
