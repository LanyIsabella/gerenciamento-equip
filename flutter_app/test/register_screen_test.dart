import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:equip_control_app/routes.dart';
import 'package:equip_control_app/screens/home_screen.dart';
import 'package:equip_control_app/screens/register_screen.dart';
import 'package:equip_control_app/services/sessao_service.dart';

import 'fake_auth_repository.dart';

void main() {
  testWidgets('mostra erro de cadastro sem expor status ou JSON',
      (tester) async {
    final repository = FakeAuthRepository()
      ..erroNoCadastro = 'E-mail já cadastrado';

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SessaoService(repository),
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail já cadastrado'), findsOneWidget);
    expect(find.textContaining('409'), findsNothing);
    expect(find.textContaining('detail'), findsNothing);
  });

  testWidgets('cadastro bem-sucedido abre a tela inicial', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SessaoService(FakeAuthRepository()),
        child: MaterialApp(
          initialRoute: AppRoutes.register,
          routes: {
            AppRoutes.register: (_) => const RegisterScreen(),
            AppRoutes.home: (_) => const HomeScreen(),
          },
        ),
      ),
    );

    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
