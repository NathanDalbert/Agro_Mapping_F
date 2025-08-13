// lib/ui/widgets/role_selection_card.dart
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class RoleSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const RoleSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Card(
        elevation: 0,
        color: isSelected ? primaryColor.withOpacity(0.1) : cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 16, 16),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: (val) => onChanged(val!),
                activeColor: primaryColor,
              ),
              Icon(icon, color: isSelected ? primaryColor : textColor),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
