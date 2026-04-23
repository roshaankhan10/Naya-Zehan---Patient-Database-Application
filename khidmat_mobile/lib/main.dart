import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'screens/login_screen.dart';
import 'screens/patient_list_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'screens/add_admission_screen.dart';
import 'screens/admissions_list_screen.dart';
import 'screens/admission_detail_screen.dart';

void main() {
  runApp(const KhidmatApp());
}

class KhidmatApp extends StatelessWidget {
  const KhidmatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Naya Zehan — Patient Records',
            theme: AppTheme.lightTheme,
            // Route based on auth state
            home: auth.isLoggedIn
                ? const PatientListScreen()
                : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/patients': (context) => const PatientListScreen(),
              '/add_patient': (context) => const AddPatientScreen(),
              '/admissions': (context) => const AdmissionsListScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/patient_detail') {
                final hospitalId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) =>
                      PatientDetailScreen(hospitalId: hospitalId),
                );
              }
              if (settings.name == '/add_admission') {
                final hospitalId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) =>
                      AddAdmissionScreen(hospitalId: hospitalId),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
