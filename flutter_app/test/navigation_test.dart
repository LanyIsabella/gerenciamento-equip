import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:equip_control_app/routes.dart';
import 'package:equip_control_app/screens/home_screen.dart';
import 'package:equip_control_app/screens/login_screen.dart';
import 'package:equip_control_app/services/sessao_service.dart';
import 'package:equip_control_app/widgets/route_guard.dart';

import 'fake_auth_repository.dart';

void main() {
  testWidgets('guarda redireciona rota protegida para o login', (tester) async {
    final service = SessaoService(FakeAuthRepository());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: service,
        child: MaterialApp(
          initialRoute: AppRoutes.home,
          routes: {
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.home: (_) => const RouteGuard(child: HomeScreen()),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('menu mostra usuário e sair limpa a pilha', (tester) async {
    final service = SessaoService(FakeAuthRepository());
    await service.entrar('teste@exemplo.com', 'senha123');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: service,
        child: MaterialApp(
          initialRoute: AppRoutes.home,
          routes: {
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.home: (_) => const RouteGuard(child: HomeScreen()),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Usuário Teste'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(service.autenticada, isFalse);
  });
}
