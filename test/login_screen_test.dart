import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/providers/character_provider.dart';

void main() {
  testWidgets('LoginScreen - verifica elementos e interação',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => CharacterProvider(),
          child: LoginScreen(),
        ),
      ),
    );

    // Verifica se os campos de email e senha estão presentes.
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);

    // Verifica se o botão de login está presente.
    expect(find.text('Login'), findsOneWidget);

    // Insere texto nos campos de email e senha.
    await tester.enterText(
        find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Simula o clique no botão de login.
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verifica se não há erro de validação.
    expect(find.text('Por favor, insira seu email'), findsNothing);
    expect(find.text('Por favor, insira sua senha'), findsNothing);
  });
}
