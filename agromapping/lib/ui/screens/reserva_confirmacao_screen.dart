import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/models/reserva.dart';
import '../../utils/colors.dart';

class ReservaConfirmacaoScreen extends StatelessWidget {
  final Reserva reserva;

  const ReservaConfirmacaoScreen({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Reserva Confirmada'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSuccessBadge(),
            const SizedBox(height: 32),
            _buildQrCard(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 32),
            _buildDoneButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: primaryColor, size: 48),
        ),
        const SizedBox(height: 16),
        const Text(
          'Reserva realizada com sucesso!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Apresente este QR Code na feira para retirar seu produto.',
          style: TextStyle(fontSize: 14, color: subtitleColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQrCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          QrImageView(
            data: reserva.qrCodeHash,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            reserva.qrCodeHash.length >= 8
                ? reserva.qrCodeHash.substring(0, 8).toUpperCase()
                : reserva.qrCodeHash.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              color: subtitleColor,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _infoRow(Icons.shopping_bag_outlined, 'Produto', reserva.produtoNome),
          const Divider(height: 20),
          _infoRow(Icons.confirmation_number_outlined, 'Quantidade',
              '${reserva.quantidade} unidade(s)'),
          const Divider(height: 20),
          _infoRow(Icons.store_outlined, 'Feira',
              reserva.feiraNome ?? 'Não especificada'),
          const Divider(height: 20),
          _infoRow(Icons.calendar_today_outlined, 'Data', reserva.dataReserva),
          const Divider(height: 20),
          _infoRow(Icons.info_outline, 'Status', reserva.status,
              valueColor: primaryColor),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 14, color: subtitleColor)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Voltar ao início',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
