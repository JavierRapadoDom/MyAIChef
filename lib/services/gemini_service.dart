import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: 'AIzaSyD1xy0jfCYIqJDZp5_PiHPCht0Q2KTGj74');

  Future<String> getRecipe(String dishName) async {
    final prompt = '''
    Eres un experto chef. Devuelve la receta del siguiente plato con la siguiente estructura clara:

- Título
- Ingredientes (en lista)
- Pasos a seguir (en lista numerada)
- Consejos adicionales

Si el plato no es válido o es inapropiado (ej: "rata podrida a la carbonara"), responde únicamente:
"Esa receta incumple nuestras normas"

Plato: $dishName
    ''';
    try{
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Error al generar respuesta.';
    } catch(e){
      return 'Error al conectar con la API: $e';
    }
  }
}
