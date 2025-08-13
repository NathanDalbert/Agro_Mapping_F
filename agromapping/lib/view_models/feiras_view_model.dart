// lib/view_models/feiras_view_model.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// Removido latlong2, usando apenas geolocator
import 'package:permission_handler/permission_handler.dart';

import '../data/models/feira.dart';
import '../data/services/feira_service.dart';

enum ViewState { idle, loading, success, error }

class FeirasViewModel extends ChangeNotifier {
  final FeiraService _feiraService = FeiraService();

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Feira> _feiras = [];
  List<Feira> get feiras => _feiras;

  Position? _userLocation;
  Position? get userLocation => _userLocation;

  PermissionStatus? _permissionStatus;
  PermissionStatus? get permissionStatus => _permissionStatus;

  FeirasViewModel() {
    initialize();
  }

  Future<void> initialize() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      // Pede permissão e busca a localização do utilizador
      final hasPermission = await requestLocationPermission();

      if (hasPermission) {
        await _getUserLocation();
      } else {
        // Se a permissão for negada, usa uma localização padrão
        _userLocation = Position(
          latitude: -23.55052,
          longitude: -46.633308,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }

      // Busca a lista de feiras na API
      _feiras = await _feiraService.getFeiras();
      _state = ViewState.success;
    } catch (e) {
      print(e);
      _state = ViewState.error;
    }
    notifyListeners();
  }

  // Novo método para solicitar a permissão
  Future<bool> requestLocationPermission() async {
    // Verifica o status atual da permissão
    _permissionStatus = await Permission.location.status;

    if (_permissionStatus == PermissionStatus.granted) {
      return true;
    }

    if (_permissionStatus == PermissionStatus.denied) {
      // Se negada, solicita a permissão ao utilizador
      final status = await Permission.location.request();
      _permissionStatus = status;
      notifyListeners();
      return status == PermissionStatus.granted;
    }

    // Se a permissão estiver permanentemente negada ou restrita, não podemos pedir novamente
    if (_permissionStatus == PermissionStatus.permanentlyDenied ||
        _permissionStatus == PermissionStatus.restricted) {
      notifyListeners();
      return false;
    }

    return false;
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _userLocation = position;
    } catch (e) {
      // Se falhar, usa uma localização padrão (São Paulo)
      _userLocation = Position(
        latitude: -23.55052,
        longitude: -46.633308,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }
  }
}
