import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/sessao_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    final sessao = context.read<SessaoService>();
    final entrou =
        await sessao.entrar(emailController.text, senhaController.text);
    if (entrou && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoService>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 30),
                    Text('Acessar sua conta',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text('Entre para acompanhar seus equipamentos.',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock_outline)),
                    ),
                    if (sessao.erro != null) ...[
                      const SizedBox(height: 14),
                      Text(sessao.erro!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: sessao.carregando ? null : entrar,
                        child:
                            Text(sessao.carregando ? 'Entrando...' : 'Entrar'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.register),
                      child: const Text('Criar cadastro'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.build, color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 12),
        const Text('EquipControl',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary)),
      ],
    );
  }
}
