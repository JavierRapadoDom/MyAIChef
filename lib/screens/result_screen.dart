import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String recipe;
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> _videos = [];
  bool _isLoadingVideos = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recipe = ModalRoute.of(context)?.settings.arguments as String;
    final title = _extractDishTitle(recipe);
    _controller.text = title;
    _loadVideos(title);
  }

  String _extractDishTitle(String recipe) {
    final lines = recipe.split('\n');
    for (var line in lines) {
      if (line.toLowerCase().startsWith('título')) {
        return line.replaceFirst(RegExp(r'título[:\-]?', caseSensitive: false), '').trim();
      }
    }
    return recipe.split('\n').first.trim();
  }

  Future<void> _loadVideos(String query) async {
    setState(() => _isLoadingVideos = true);
    try {
      final results = await fetchYoutubeVideos(query);
      setState(() => _videos = results);
    } catch (_) {
      setState(() => _videos = []);
    } finally {
      setState(() => _isLoadingVideos = false);
    }
  }

  Future<List<Map<String, String>>> fetchYoutubeVideos(String query) async {
    const apiKey = 'TU_YOUTUBE_API_KEY'; // reemplaza aquí con tu API Key
    final uri = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/search',
      {
        'part': 'snippet',
        'q': '$query receta',
        'type': 'video',
        'maxResults': '3',
        'key': apiKey,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error al cargar los videos');
    }

    final data = json.decode(response.body);
    final List items = data['items'] ?? [];
    return items.map<Map<String, String>>((item) {
      return {
        'id': item['id']['videoId'],
        'title': item['snippet']['title'],
        'thumbnail': item['snippet']['thumbnails']['high']['url'],
      };
    }).toList();
  }

  Future<void> _launchVideo(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el vídeo')),
      );
    }
  }

  void _searchNewRecipe() {
    final newDish = _controller.text.trim();
    if (newDish.isNotEmpty) Navigator.pop(context, newDish);
  }

  Text _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    ),
  );

  Text _listItem(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      height: 1.5,
      fontFamily: 'Poppins',
    ),
  );

  Text _numberedItem(int index, String text) => Text(
    '$index. $text',
    style: const TextStyle(
      fontSize: 16,
      height: 1.5,
      fontFamily: 'Poppins',
    ),
  );

  List<Widget> _parseRecipe(String recipe) {
    final lines = recipe.split('\n');
    final List<Widget> widgets = [];
    String? currentSection;
    int stepCounter = 1;

    for (var line in lines) {
      final t = line.trim();
      if (t.isEmpty) continue;

      final l = t.toLowerCase();
      if (l.startsWith('título') ||
          l.startsWith('ingredientes') ||
          l.startsWith('pasos') ||
          l.startsWith('consejos')) {
        currentSection = t;
        widgets.add(const SizedBox(height: 20));
        widgets.add(_sectionTitle(currentSection));
        if (l.startsWith('pasos')) stepCounter = 1;
      } else {
        if (currentSection != null && currentSection.toLowerCase().contains('pasos')) {
          widgets.add(_numberedItem(stepCounter++, t.replaceFirst(RegExp(r'^\d+[\).]?\s*'), '')));
        } else {
          widgets.add(_listItem(t.replaceFirst(RegExp(r'^[-•]?\s*'), '')));
        }
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6FCF97),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Buscar receta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Introduzca aquí el plato que desee',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _searchNewRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Buscar', style: TextStyle(fontFamily: 'Poppins')),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Bloque de receta
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _parseRecipe(recipe),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Videos relacionados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              if (_isLoadingVideos)
                const Center(child: CircularProgressIndicator())
              else if (_videos.isEmpty)
                const Text('No se encontraron videos.', style: TextStyle(fontFamily: 'Poppins'))
              else
                Column(
                  children: _videos.map((video) {
                    return GestureDetector(
                      onTap: () => _launchVideo(video['id']!),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: Image.network(
                                video['thumbnail']!,
                                width: 120,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  video['title']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
