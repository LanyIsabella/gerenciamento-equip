import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/sessao_service.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.build, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'EquipControl',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  usuario?.nome ?? 'Usuário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  usuario?.email ?? '',
                  style:
                      const TextStyle(color: Color(0xFFDCE2D7), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'NAVEGAÇÃO',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () => _navegar(context, AppRoutes.home),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Equipamentos'),
            onTap: () => _navegar(context, AppRoutes.equipamentos),
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text('Manutenções'),
            onTap: () => _navegar(context, AppRoutes.manutencoes),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              'CONTA',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            onTap: () => _navegar(context, AppRoutes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              await context.read<SessaoService>().sair();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _navegar(BuildContext context, String rota) {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed(rota);
  }
}
