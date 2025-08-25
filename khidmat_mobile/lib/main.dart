import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/patient_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khidmat App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/patients': (context) => const PatientListScreen(),
      },
    );
  }
}
