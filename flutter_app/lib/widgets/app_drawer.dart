import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/sessao_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(usuario?.nome ?? 'Usuário'),
            accountEmail: Text(usuario?.email ?? ''),
            currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () => _navegar(context, AppRoutes.home),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () => _navegar(context, AppRoutes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Livros'),
            onTap: () => _navegar(context, AppRoutes.books),
          ),
          const Divider(),
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
