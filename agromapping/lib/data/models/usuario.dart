// lib/data/models/usuario.dart

class Usuario {
  final String id;
  final String nome;
  final String email;
  final String userRole; // "USER", "SELLER", "ADMIN"

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.userRole,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      userRole: json['userRole'] ?? 'USER', // Garante um valor padrão
    );
  }

  // Helper para saber se o utilizador é um vendedor
  bool get isSeller => userRole == 'SELLER';
}
