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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(create: (_) => QuestProvider()),
        ChangeNotifierProvider(create: (_) => CombatProvider()),
      ],
      child: MaterialApp(
        title: 'Fitness RPG',
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (context) => AppWrapper(),
          '/profile': (context) => ProfileScreen(),
          '/quests': (context) => QuestScreen(),
          '/combat': (context) => CombatScreen(),
        },
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final userId = snapshot.data!.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<CharacterProvider>(context, listen: false)
                .loadCharacter(userId: userId);
          });

          return ProfileScreen();
        }

        return LoginScreen();
      },
    );
  }
}
