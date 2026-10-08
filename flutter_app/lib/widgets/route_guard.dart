import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/sessao_service.dart';

class RouteGuard extends StatelessWidget {
  final Widget child;

  const RouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final autenticada = context.watch<SessaoService>().autenticada;
    if (autenticada) return child;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted &&
          ModalRoute.of(context)?.settings.name != AppRoutes.login) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
