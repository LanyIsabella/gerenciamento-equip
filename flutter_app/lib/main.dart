import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/auth_repository.dart';
import 'repositories/token_repository.dart';
import 'routes.dart';
import 'services/api_client.dart';
import 'services/sessao_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final apiClient = ApiClient(baseUrl: 'http://localhost:8000');
  final authRepository = ApiAuthRepository(apiClient);
  final sessao = SessaoService(
    authRepository,
    tokenRepository: SharedPreferencesTokenRepository(preferences),
  );
  await sessao.restaurar();

  runApp(
    ChangeNotifierProvider.value(
      value: sessao,
      child: EquipControlApp(
        initialRoute: sessao.autenticada ? AppRoutes.home : AppRoutes.login,
      ),
    ),
  );
}

class EquipControlApp extends StatelessWidget {
  final String initialRoute;

  const EquipControlApp({
    super.key,
    this.initialRoute = AppRoutes.login,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EquipControl',
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
