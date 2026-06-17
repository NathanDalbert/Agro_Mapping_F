import 'package:flutter/material.dart';

import '../../data/models/reserva.dart';
import '../../data/services/reserva_service.dart';
import '../../utils/colors.dart';
import 'qr_scanner_screen.dart';

class DashboardVendedorScreen extends StatefulWidget {
  const DashboardVendedorScreen({super.key});

  @override
  State<DashboardVendedorScreen> createState() => _DashboardVendedorScreenState();
}

class _DashboardVendedorScreenState extends State<DashboardVendedorScreen> {
  final ReservaService _service = ReservaService();
  late Future<List<Reserva>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getReservasVendedor();
  }

  void _reload() => setState(() { _future = _service.getReservasVendedor(); });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<Reserva>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: primaryColor));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: dangerColor),
                          const SizedBox(height: 12),
                          Text('${snapshot.error}',
                              style: const TextStyle(color: subtitleColor),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _reload,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }
                  final reservas = snapshot.data ?? [];
                  if (reservas.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: successColor),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma reserva pendente',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Todas as retiradas estão em dia!',
                            style: TextStyle(color: subtitleColor),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () async => _reload(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reservas.length,
                      itemBuilder: (_, i) => _ReservaVendedorCard(
                        reserva: reservas[i],
                        onUpdated: _reload,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: cardColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_outlined, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
              ),
              Text(
                'Reservas pendentes dos seus produtos',
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh, color: primaryColor),
            tooltip: 'Atualizar',
          ),
        ],
      ),
    );
  }
}

class _ReservaVendedorCard extends StatefulWidget {
  final Reserva reserva;
  final VoidCallback onUpdated;

  const _ReservaVendedorCard({required this.reserva, required this.onUpdated});

  @override
  State<_ReservaVendedorCard> createState() => _ReservaVendedorCardState();
}

class _ReservaVendedorCardState extends State<_ReservaVendedorCard> {
  bool _loading = false;

  Color get _statusColor {
    switch (widget.reserva.status) {
      case 'CONFIRMADA':
        return Colors.blue;
      case 'PENDENTE':
        return warningColor;
      default:
        return subtitleColor;
    }
  }

  Future<void> _confirmarRetirada() async {
    // Abre câmera para leitura do QR; retorna true (scan OK) ou 'manual'
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(
          expectedHash: widget.reserva.qrCodeHash,
          produtoNome: widget.reserva.produtoNome,
        ),
      ),
    );

    // null = usuário cancelou
    if (result == null || !mounted) return;

    // result == true → QR bateu; result == 'manual' → confirmação sem QR
    final bool confirmar = result == true || result == 'manual';
    if (!confirmar) return;

    setState(() { _loading = true; });
    try {
      await ReservaService().confirmarRetirada(widget.reserva.idReserva);
      widget.onUpdated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar: $e'),
              backgroundColor: dangerColor),
        );
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reserva;
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.produtoNome,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    r.status,
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.qr_code, size: 14, color: subtitleColor),
                const SizedBox(width: 4),
                Text(
                  r.qrCodeHash.length >= 8
                      ? r.qrCodeHash.substring(0, 8).toUpperCase()
                      : r.qrCodeHash.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                      fontFamily: 'monospace',
                      letterSpacing: 1.5),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.confirmation_number_outlined,
                    size: 14, color: subtitleColor),
                const SizedBox(width: 4),
                Text('${r.quantidade} un.',
                    style:
                        const TextStyle(fontSize: 12, color: subtitleColor)),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: subtitleColor),
                const SizedBox(width: 4),
                Text(r.dataReserva,
                    style:
                        const TextStyle(fontSize: 12, color: subtitleColor)),
              ],
            ),
            if (r.feiraNome != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.store_outlined, size: 14, color: subtitleColor),
                  const SizedBox(width: 4),
                  Text(r.feiraNome!,
                      style: const TextStyle(fontSize: 12, color: subtitleColor)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _confirmarRetirada,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(_loading ? 'Confirmando...' : 'Confirmar Retirada'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
