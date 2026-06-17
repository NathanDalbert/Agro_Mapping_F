import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/models/reserva.dart';
import '../../data/services/reserva_service.dart';
import '../../utils/colors.dart';

class MinhasReservasScreen extends StatefulWidget {
  const MinhasReservasScreen({super.key});

  @override
  State<MinhasReservasScreen> createState() => _MinhasReservasScreenState();
}

class _MinhasReservasScreenState extends State<MinhasReservasScreen> {
  final ReservaService _service = ReservaService();
  late Future<List<Reserva>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMinhasReservas();
  }

  void _reload() => setState(() => _future = _service.getMinhasReservas());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Minhas Reservas')),
      body: FutureBuilder<List<Reserva>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar reservas: ${snapshot.error}'));
          }
          final reservas = snapshot.data ?? [];
          if (reservas.isEmpty) {
            return const Center(
              child: Text('Você ainda não possui nenhuma reserva.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservas.length,
            itemBuilder: (_, i) => _ReservaCard(
              reserva: reservas[i],
              onCanceled: _reload,
            ),
          );
        },
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final VoidCallback onCanceled;

  const _ReservaCard({required this.reserva, required this.onCanceled});

  Color get _statusColor {
    switch (reserva.status) {
      case 'CONFIRMADA':
        return Colors.blue;
      case 'RETIRADA':
        return successColor;
      case 'CANCELADA':
        return dangerColor;
      default:
        return warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reserva.produtoNome,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                ),
                _StatusBadge(status: reserva.status, color: _statusColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              reserva.feiraNome ?? 'Feira não especificada',
              style: const TextStyle(fontSize: 13, color: subtitleColor),
            ),
            const SizedBox(height: 4),
            Text(
              '${reserva.quantidade} unidade(s) • ${reserva.dataReserva}',
              style: const TextStyle(fontSize: 13, color: subtitleColor),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showQrDialog(context),
                  icon: const Icon(Icons.qr_code, size: 18),
                  label: const Text('Ver QR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (reserva.isPendente) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _cancelar(context),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dangerColor,
                      side: const BorderSide(color: dangerColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(reserva.produtoNome),
        content: SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: reserva.qrCodeHash,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                reserva.qrCodeHash.length >= 8
                    ? reserva.qrCodeHash.substring(0, 8).toUpperCase()
                    : reserva.qrCodeHash.toUpperCase(),
                style: const TextStyle(
                    color: subtitleColor,
                    letterSpacing: 2,
                    fontSize: 13,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelar(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: const Text('Tem certeza que deseja cancelar esta reserva?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sim', style: TextStyle(color: dangerColor))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ReservaService().cancelarReserva(reserva.idReserva);
      onCanceled();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar: $e')),
        );
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
