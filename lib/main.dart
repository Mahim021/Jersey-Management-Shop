import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// TODO: run flutterfire configure to generate this file
import 'firebase_options.dart';
import 'screens/auth.dart';
import 'screens/main_shell.dart';
import 'screens/verify_email.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(
      'Firebase initialization failed: $e\n'
      'Did you run `flutterfire configure` to generate lib/firebase_options.dart?',
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: AuthService().userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          if (user == null) return const AuthScreen();
          if (AuthService().needsEmailVerification(user)) {
            return const VerifyEmailScreen();
          }
          return const MainShell();
        },
      ),
    );
  }
}


