import 'package:flutter/material.dart';
import 'features/vehicle_management/presentation/pages/login_register/login_screen.dart';
import 'features/vehicle_management/presentation/pages/businessman/profile/profile_screen.dart';
import 'features/vehicle_management/presentation/pages/carrier/profile/profile_screen2.dart';

void main() {
  runApp(MoviGestionApp());
}

class MoviGestionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoviGestion',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(

        ),

      },
    );
  }
}
