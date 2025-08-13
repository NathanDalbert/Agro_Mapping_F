// lib/data/models/estoque.dart

class Estoque {
  final String idEstoque;
  final String produtoId;
  final int quantidadeDisponivel;

  Estoque({
    required this.idEstoque,
    required this.produtoId,
    required this.quantidadeDisponivel,
  });

  // Converte um JSON em um objeto Estoque
  factory Estoque.fromJson(Map<String, dynamic> json) {
    return Estoque(
      idEstoque: json['idEstoque'],
      produtoId: json['produtoId'],
      quantidadeDisponivel: json['quantidadeDisponivel'],
    );
  }
}
