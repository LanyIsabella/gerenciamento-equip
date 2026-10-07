import 'package:flutter/material.dart';

import 'repositories/auth_repository.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';

void main() {
  final apiClient = ApiClient(baseUrl: 'http://localhost:8000');
  final authRepository = ApiAuthRepository(apiClient);
  final authService = AuthService(authRepository);

  runApp(EquipControlApp(authService: authService));
}

class EquipControlApp extends StatelessWidget {
  final AuthService authService;

  const EquipControlApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EquipControl',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: LoginScreen(authService: authService),
    );
  }
}
