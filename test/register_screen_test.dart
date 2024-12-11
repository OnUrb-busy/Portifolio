import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_application_1/screens/register_screen.dart';

void main() {
  testWidgets('RegisterScreen - verifica elementos e interação',
      (WidgetTester tester) async {
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

    // Verifica se os campos de email e senha estão presentes.
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);

    // Verifica se o botão de cadastro está presente.
    expect(find.text('Cadastrar'), findsOneWidget);

    // Insere texto nos campos de email e senha.
    await tester.enterText(
        find.byType(TextFormField).at(0), 'newuser@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Simula o clique no botão de cadastro.
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    // Verifica se não há erro de validação.
    expect(find.text('Por favor, insira um email'), findsNothing);
    expect(find.text('Por favor, insira uma senha'), findsNothing);
  });
}
