import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_drawer.dart';

class AppShell extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;
  final Widget child;

  const AppShell({
    super.key,
    required this.title,
    this.description,
    this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.build, color: AppTheme.primary, size: 19),
            ),
            const SizedBox(width: 10),
            const Text(
              'EquipControl',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ajuda',
            onPressed: () => _mostrarAjuda(context),
            icon: const Icon(Icons.help_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final heading = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(letterSpacing: 0.2, fontSize: 30),
                          ),
                          if (description != null) ...[
                            const SizedBox(height: 5),
                            Text(description!,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ],
                      );

                      if (action == null || constraints.maxWidth < 620) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            heading,
                            if (action != null) ...[
                              const SizedBox(height: 16),
                              action!,
                            ],
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: heading),
                          const SizedBox(width: 16),
                          action!,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarAjuda(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('EquipControl'),
        content: const Text(
          'Use o menu para acompanhar equipamentos e ordens de manutenção.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar')),
        ],
      ),
    );
  }
}
