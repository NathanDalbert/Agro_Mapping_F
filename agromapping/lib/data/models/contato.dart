// lib/data/models/contato.dart

class Contato {
  final String id;
  final String telefone;

  Contato({
    required this.id,
    required this.telefone,
  });

  // Converte um JSON em um objeto Contato
  factory Contato.fromJson(Map<String, dynamic> json) {
    return Contato(
      id: json['id'],
      telefone: json['telefone'],
    );
  }
}
