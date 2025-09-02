import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolist/todo/todo_page.dart';
import 'error_service.dart';

final class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ErrorService _errorService = ErrorService();

  Future<void> authenticate(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    bool isLogin
  ) async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final user = isLogin
          ? await signIn(email, password)
          : await signUp(email, password);

      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorService.getAuthErrorMessage(e))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue: ${e.toString()}')),
      );
    }
  }

  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }
}
