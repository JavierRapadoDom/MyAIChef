import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget{
  const SplashScreen({super.key});

  @override
  Widget build (BuildContext context){
    Future.delayed(const Duration(seconds: 2), (){
      Navigator.pushReplacementNamed(context, '/home');
    });

    return Scaffold(
      backgroundColor: const Color(0xFF6FCF97),
      body: Center(
        child: Image.asset('assets/Logo.png', width: 150),
      ),
    );
  }
}