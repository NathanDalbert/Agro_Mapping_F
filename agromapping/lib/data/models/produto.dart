// lib/data/models/produto.dart
import 'estoque.dart';

class Produto {
  final String id;
  final String nome;
  final String categoria;
  final double preco;
  final String descricao;
  final String imagem;
  final String? usuarioId; // ID do usuário que criou o produto
  final Estoque? estoque; // Estoque pode ser nulo

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

  // Converte um JSON em um objeto Produto
  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      categoria: json['categoria'],
      preco: (json['preco'] as num).toDouble(),
      descricao: json['descricao'],
      imagem: json['imagem'],
      usuarioId: json['usuarioId'],
      estoque:
          json['estoque'] != null ? Estoque.fromJson(json['estoque']) : null,
    );
  }
}
