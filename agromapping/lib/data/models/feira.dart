// lib/data/models/feira.dart
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart'; // Import do pacote de coordenadas

class Feira {
  final String idFeira;
  final String nome;
  final String localizacao;
  final DateTime dataFuncionamento;
  final double latitude; // <<< NOVO CAMPO
  final double longitude; // <<< NOVO CAMPO

  Feira({
    required this.idFeira,
    required this.nome,
    required this.localizacao,
    required this.dataFuncionamento,
    required this.latitude,
    required this.longitude,
  });

  // Converte o objeto para um LatLng para o mapa
  LatLng get latLng => LatLng(latitude, longitude);

  factory Feira.fromJson(Map<String, dynamic> json) {
    return Feira(
      idFeira: json['idFeira'],
      nome: json['nome'],
      localizacao: json['localizacao'],
      dataFuncionamento: DateTime.parse(json['dataFuncionamento']),
      latitude: (json['latitude'] as num).toDouble(), // <<< NOVO CAMPO
      longitude: (json['longitude'] as num).toDouble(), // <<< NOVO CAMPO
    );
  }

  String get horarioFormatado {
    final diaDaSemana = DateFormat('EEEE', 'pt_BR').format(dataFuncionamento);
    // Lógica de exemplo para horários
    switch (nome) {
      case 'Feira da Liberdade':
        return 'Sábados: 7h às 14h';
      case 'Feira Orgânica do Ibirapuera':
        return 'Sábados: 8h às 17h';
      default:
        return 'Sábados: 9h às 16h';
    }
  }
}
