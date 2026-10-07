import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/sessao_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> entrar() async {
    final sessao = context.read<SessaoService>();
    final entrou = await sessao.entrar(
      emailController.text,
      senhaController.text,
    );

    if (entrou && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoService>();

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('EquipControl', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              if (sessao.erro != null) ...[
                const SizedBox(height: 12),
                Text(sessao.erro!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sessao.carregando ? null : entrar,
                      child: Text(
                        sessao.carregando ? 'Entrando...' : 'Entrar',
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.register,
                ),
                child: const Text('Criar cadastro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
