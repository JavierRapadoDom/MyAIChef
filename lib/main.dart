import 'package:flutter/material.dart';
import 'package:my_ai_chef/screens/home_screen.dart';
import 'package:my_ai_chef/screens/result_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyAIChefApp());
}

class MyAIChefApp extends StatelessWidget{
  const MyAIChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyAIChef',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/result': (context) => const ResultScreen(),
      },
    );
  }
}