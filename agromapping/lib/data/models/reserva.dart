class Reserva {
  final String idReserva;
  final String produtoNome;
  final String produtoImagem;
  final String? feiraNome;
  final int quantidade;
  final String status;
  final String dataReserva;
  final String qrCodeHash;

  Reserva({
    required this.idReserva,
    required this.produtoNome,
    required this.produtoImagem,
    this.feiraNome,
    required this.quantidade,
    required this.status,
    required this.dataReserva,
    required this.qrCodeHash,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    final produto = json['produto'] as Map<String, dynamic>? ?? {};
    final feira = json['feira'] as Map<String, dynamic>?;
    return Reserva(
      idReserva: json['idReserva']?.toString() ?? '',
      produtoNome: produto['nome']?.toString() ?? '',
      produtoImagem: produto['imagem']?.toString() ?? '',
      feiraNome: feira?['nome']?.toString(),
      quantidade: json['quantidade'] as int? ?? 1,
      status: json['status']?.toString() ?? 'PENDENTE',
      dataReserva: json['dataReserva']?.toString() ?? '',
      qrCodeHash: json['qrCodeHash']?.toString() ?? '',
    );
  }

  bool get isPendente => status == 'PENDENTE';
}
