import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final positive = status == 'Ativo' || status == 'Concluída';
    final warning = status == 'Em Manutenção' ||
        status == 'Em Andamento' ||
        status == 'Pendente';
    final color = positive
        ? const Color(0xFFDCEFD9)
        : warning
            ? const Color(0xFFF8E8B8)
            : const Color(0xFFE8EBE5);
    final foreground = positive
        ? const Color(0xFF397044)
        : warning
            ? const Color(0xFF80651B)
            : AppTheme.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
