import 'estoque.dart';

class Produto {
  final String id;
  final String nome;
  final String categoria;
  final double preco;
  final String descricao;
  final String imagem;
  final String? usuarioId;
  final Estoque? estoque;

  Produto({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.descricao,
    required this.imagem,
    this.usuarioId,
    this.estoque,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id']?.toString() ?? '',
      nome: json['nome'] ?? '',
      categoria: json['categoria'] ?? '',
      preco: (json['preco'] as num?)?.toDouble() ?? 0.0,
      descricao: json['descricao'] ?? '',
      imagem: json['imagem'] ?? '',
      usuarioId: json['usuarioId']?.toString(),
      estoque: json['estoque'] != null
          ? Estoque.fromJson(json['estoque'])
          : null,
    );
  }
}
