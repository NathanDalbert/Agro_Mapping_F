// lib/view_models/contatos_view_model.dart
import 'package:agromapping/data/models/contato.dart';
import 'package:agromapping/data/services/contato_service.dart';
import 'package:flutter/material.dart';

enum ViewState { idle, loading, success, error }

class ContatosViewModel extends ChangeNotifier {
  final ContatoService _contatoService = ContatoService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Contato> _contatos = [];
  List<Contato> get contatos => _contatos;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ContatosViewModel() {
    fetchContatos();
  }

  Future<void> fetchContatos() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _contatos = await _contatoService.getMeusContatos();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<bool> addContato(String telefone) async {
    try {
      await _contatoService.createContato(telefone);
      await fetchContatos(); // Atualiza a lista após adicionar
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateContato(String id, String novoTelefone) async {
    try {
      await _contatoService.updateContato(id, novoTelefone);
      await fetchContatos(); // Atualiza a lista após editar
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteContato(String id) async {
    try {
      await _contatoService.deleteContato(id);
      _contatos.removeWhere((contato) =>
          contato.id ==
          id); // Remove da lista localmente para uma UI mais rápida
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
