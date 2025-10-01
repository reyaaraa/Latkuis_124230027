import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const VehicleApp());
}

class VehicleApp extends StatelessWidget {
  const VehicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
