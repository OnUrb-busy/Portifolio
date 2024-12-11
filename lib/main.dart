import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/character_provider.dart';
import 'providers/quest_provider.dart';
import 'providers/combat_provider.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/combat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configuração do Firebase
    const firebaseConfig = FirebaseOptions(
      apiKey: "AIzaSyDWOQJbM9LinPn9COBj3GHXh4oOsNUa3n0",
      authDomain: "questyourselfy.firebaseapp.com",
      projectId: "questyourselfy",
      storageBucket: "questyourselfy.firebasestorage.app",
      messagingSenderId: "429644857495",
      appId: "1:429644857495:web:b6dcaa5595f14066eca9d2",
    );

    await Firebase.initializeApp(options: firebaseConfig);
    print("Firebase inicializado com sucesso!");
  } catch (e) {
    print("Erro ao inicializar Firebase: $e");
  }

  runApp(FitnessRPGApp());
}

class FitnessRPGApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final userId = snapshot.data!.uid;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) {
                  final characterProvider = CharacterProvider();
                  characterProvider.loadCharacter(userId: userId);
                  return characterProvider;
                },
              ),
              ChangeNotifierProvider(
                create: (context) {
                  final characterProvider =
                      Provider.of<CharacterProvider>(context, listen: false);
                  return QuestProvider(
                      userId: userId, characterProvider: characterProvider);
                },
              ),
              ChangeNotifierProvider(create: (_) => CombatProvider()),
            ],
            child: MaterialApp(
              title: 'Fitness RPG',
              theme: ThemeData.dark(),
              initialRoute: '/profile',
              routes: {
                '/profile': (context) => ProfileScreen(),
                '/quests': (context) => QuestScreen(),
                '/combat': (context) => CombatScreen(),
              },
            ),
          );
        }

        return MaterialApp(
          title: 'Fitness RPG',
          theme: ThemeData.dark(),
          home: LoginScreen(),
        );
      },
    );
  }
}
