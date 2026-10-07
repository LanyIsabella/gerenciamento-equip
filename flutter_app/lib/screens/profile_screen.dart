import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sessao_service.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      drawer: const AppDrawer(),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${usuario?.nome ?? ''}'),
            Text('E-mail: ${usuario?.email ?? ''}'),
          ],
        ),
      ),
    );
  }
}
