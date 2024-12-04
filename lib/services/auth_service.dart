import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> register(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Usuário registrado com sucesso: $email');
      return true;
    } catch (e) {
      print('Erro ao registrar usuário: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Usuário autenticado com sucesso: $email');
      return true;
    } catch (e) {
      print('Erro ao autenticar usuário: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      print('Usuário desconectado.');
    } catch (e) {
      print('Erro ao desconectar: $e');
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
