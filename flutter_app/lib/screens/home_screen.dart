import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sessao_service.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SessaoService>().usuario;

    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      drawer: const AppDrawer(),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${usuario?.nome ?? 'usuário'}!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text('E-mail: ${usuario?.email ?? ''}'),
            Text('Cargo: ${usuario?.cargo ?? ''}'),
          ],
        ),
      ),
    );
  }
}
