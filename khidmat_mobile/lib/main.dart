import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/patient_list_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'screens/add_admission_screen.dart';
import 'screens/admissions_list_screen.dart';
import 'screens/admission_detail_screen.dart';
import 'screens/add_admission_screen.dart';

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/patients': (context) => const PatientListScreen(),
        '/add_patient': (context) => const AddPatientScreen(),
        '/admissions': (context) => const AdmissionsListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/patient_detail') {
          final patient = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PatientDetailScreen(patient: patient),
          );
        }
        if (settings.name == '/add_admission') {
          final hospitalId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => AddAdmissionScreen(hospitalId: hospitalId),
          );
        }
        return null;
      },
    );
  }
}
