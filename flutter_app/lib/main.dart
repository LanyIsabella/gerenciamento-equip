import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/auth_repository.dart';
import 'routes.dart';
import 'services/api_client.dart';
import 'services/sessao_service.dart';

void main() {
  final apiClient = ApiClient(baseUrl: 'http://localhost:8000');
  final repository = ApiAuthRepository(apiClient);

  runApp(
    ChangeNotifierProvider(
      create: (_) => SessaoService(repository),
      child: const EquipControlApp(),
    ),
  );
}

class EquipControlApp extends StatelessWidget {
  const EquipControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EquipControl',
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
