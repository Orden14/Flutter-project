import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'todo/todo_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  final env = dotenv.env['ENV'] ?? 'dev';
  if (env == 'prod') {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

final class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final env = dotenv.env['ENV'] ?? 'dev';

    if (env != 'prod') {
      return const MaterialApp(
        title: 'Flutter Firebase Auth',
        home: TodoPage(),
      );
    }

    return MaterialApp(
      title: 'Flutter Firebase Auth',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const TodoPage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
