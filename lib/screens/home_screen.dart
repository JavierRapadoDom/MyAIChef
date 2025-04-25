import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _loading = false;

  void _searchRecipe() async {
    setState(() {
      _loading = true;
    });

    final recipe = await _geminiService.getRecipe(_controller.text.trim());

    setState(() {
      _loading = false;
    });

    Navigator.pushNamed(
      context,
      '/result',
      arguments: recipe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6FCF97),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Buscar receta',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Introduzca aquí el plato que desee',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
              ),
            ),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _searchRecipe,
              child: const Text('Buscar'),
            ),
          ],
        ),
      ),
    );
  }
}
