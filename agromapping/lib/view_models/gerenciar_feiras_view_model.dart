import 'package:flutter/material.dart';

import '../data/models/feira.dart';
import '../data/services/feira_service.dart';

enum ViewState { idle, loading, success, error }

class GerenciarFeirasViewModel extends ChangeNotifier {
  final FeiraService _feiraService = FeiraService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Feira> _feiras = [];
  List<Feira> get feiras => _feiras;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  GerenciarFeirasViewModel() {
    fetchFeiras();
  }

  Future<void> fetchFeiras() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _feiras = await _feiraService.getFeiras();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> criarFeira({
    required String nome,
    required String localizacao,
    required String dataFuncionamento,
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    notifyListeners();

    final success = await _feiraService.criarFeira(
      nome: nome,
      localizacao: localizacao,
      dataFuncionamento: dataFuncionamento,
      latitude: latitude,
      longitude: longitude,
    );

    if (success) await fetchFeiras();

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deletarFeira(String feiraId) async {
    final success = await _feiraService.deletarFeira(feiraId);
    if (success) {
      _feiras.removeWhere((f) => f.idFeira == feiraId);
      notifyListeners();
    }
    return success;
  }
}
