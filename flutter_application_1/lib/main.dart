import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/matkul.dart';
import 'package:flutter_application_1/profil.dart';
import 'package:flutter_application_1/register.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      routes: {
        '/': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/profil': (context) => ProfilPage(),
        '/matkul': (context) => matkul(),
      },
    );
  }
}