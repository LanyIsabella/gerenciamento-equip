import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  String? erro;
  bool carregando = false;

  Future<void> entrar() async {
    setState(() {
      erro = null;
      carregando = true;
    });
    try {
      await widget.authService.login(
        emailController.text,
        senhaController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(authService: widget.authService),
        ),
      );
    } on ApiException catch (exception) {
      setState(() => erro = exception.message);
    } catch (_) {
      setState(() => erro = 'Não foi possível conectar à API');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'E-mail')),
              TextField(controller: senhaController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
              if (erro != null) ...[
                const SizedBox(height: 12),
                Text(erro!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: carregando ? null : entrar,
                      child: Text(carregando ? 'Entrando...' : 'Entrar'),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RegisterScreen(authService: widget.authService),
                  ),
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
