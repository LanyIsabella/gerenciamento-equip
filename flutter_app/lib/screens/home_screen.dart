import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final usuario = authService.usuario;
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, ${usuario?.nome ?? 'usuário'}!', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            Text('E-mail: ${usuario?.email ?? ''}'),
            Text('Cargo: ${usuario?.cargo ?? ''}'),
          ],
        ),
      ),
    );
  }
}
