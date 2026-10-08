import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/auth_repository.dart';
import 'repositories/equipamentos_repository.dart';
import 'repositories/manutencoes_repository.dart';
import 'repositories/token_repository.dart';
import 'routes.dart';
import 'services/api_client.dart';
import 'services/equipamentos_service.dart';
import 'services/manutencoes_service.dart';
import 'services/sessao_service.dart';
import 'theme/app_theme.dart';

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessao),
        ChangeNotifierProvider(
          create: (_) => EquipamentosService(
            ApiEquipamentosRepository(apiClient, () => sessao.token),
            sessao,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ManutencoesService(
            ApiManutencoesRepository(apiClient, () => sessao.token),
            sessao,
          ),
        ),
      ],
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
      theme: AppTheme.light(),
    );
  }
}
