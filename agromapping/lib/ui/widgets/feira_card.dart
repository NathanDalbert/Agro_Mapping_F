// lib/ui/widgets/feira_card.dart
import 'package:flutter/material.dart';

import '../../data/models/feira.dart';
import '../../utils/colors.dart';

class FeiraCard extends StatelessWidget {
  final Feira feira;

  const FeiraCard({super.key, required this.feira});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: Icon(Icons.location_on),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feira.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feira.localizacao,
                    style: const TextStyle(fontSize: 14, color: subtitleColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feira.horarioFormatado,
                    style: const TextStyle(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_outlined, color: primaryColor),
              onPressed: () {
                /* Lógica para abrir no mapa */
              },
            ),
          ],
        ),
      ),
    );
  }
}
