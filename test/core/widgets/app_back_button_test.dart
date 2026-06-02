import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:startinvest/core/widgets/app_back_button.dart';

void main() {
  group('AppBackButton Widget Tests', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBackButton(),
          ),
        ),
      );

      expect(find.byType(AppBackButton), findsOneWidget);
      // Verifica se o widget interno BackButton do Flutter está presente
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('should call context.pop() when pressed and can pop', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/second',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('Home'))),
          GoRoute(path: '/second', builder: (context, state) => const Scaffold(body: AppBackButton())),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Simula o clique no botão
      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      // Verifica se voltou para a Home
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
