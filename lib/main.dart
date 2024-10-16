import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart'; // Importa a ProfileScreen
import 'providers/character_provider.dart';

void main() {
  runApp(FitnessRPGApp());
}

class FitnessRPGApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: MaterialApp(
        title: 'Fitness RPG',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Define as rotas do aplicativo
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/profile': (context) => ProfileScreen(), // Rota para a ProfileScreen
        },
      ),
    );
  }
}
