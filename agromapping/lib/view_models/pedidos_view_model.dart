import 'package:flutter/material.dart';

import '../data/models/pedido.dart';
import '../data/services/pedido_service.dart';
import '../utils/view_state.dart';

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
      final index = _pedidos.indexWhere((p) => p.id == pedidoId);
      if (index != -1) {
        _pedidos[index] = Pedido(
          id: _pedidos[index].id,
          dataPedido: _pedidos[index].dataPedido,
          valorTotal: _pedidos[index].valorTotal,
          itens: _pedidos[index].itens,
          status: 'CANCELADO',
        );
        notifyListeners();
      }
    }
    return success;
  }
}
