import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sessao_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario;
    return AppShell(
      title: 'Perfil',
      description: 'Dados da conta atualmente conectada.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFE7EDDE),
                    child: Text(
                      (usuario?.nome.isNotEmpty ?? false)
                          ? usuario!.nome[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario?.nome ?? '',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(usuario?.cargo ?? '',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),
              _ItemPerfil(label: 'Nome completo', value: usuario?.nome ?? ''),
              _ItemPerfil(label: 'E-mail', value: usuario?.email ?? ''),
              _ItemPerfil(
                  label: 'Perfil de acesso', value: usuario?.cargo ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemPerfil extends StatelessWidget {
  final String label;
  final String value;

  const _ItemPerfil({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
