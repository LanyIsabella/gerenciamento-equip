import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;

  const RegisterScreen({super.key, required this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  String? mensagem;

  Future<void> cadastrar() async {
    try {
      await widget.authService.cadastrar(
        nomeController.text,
        emailController.text,
        senhaController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (exception) {
      setState(() => mensagem = exception.message);
    } catch (_) {
      setState(() => mensagem = 'Não foi possível conectar à API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'E-mail')),
            TextField(controller: senhaController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
            if (mensagem != null) Text(mensagem!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: ElevatedButton(onPressed: cadastrar, child: const Text('Cadastrar')))]),
          ],
        ),
      ),
    );
  }
}
