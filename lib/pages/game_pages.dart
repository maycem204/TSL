import 'package:flutter/material.dart';
import 'ai_recognition.dart';
import 'interactive_video_page.dart';
import 'find_image_game.dart';
import 'write_word_game.dart';
import 'dictionary_page.dart';
import '../widgets/navigation_wrapper.dart';
import 'dart:math';

const Color primaryRed = Color(0xFFE60012);
const Color bgGrey = Color(0xFFF5F5F5);
const Color lightRed = Color(0xFFFFE5E5);

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _sparkleController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _sparkleAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    _floatingController.repeat(reverse: true);
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationWrapper(
      selectedIndex: 2, // Games index
      child: Scaffold(
        backgroundColor: bgGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryRed),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            "Jeux & Apprentissage",
            style: TextStyle(
              color: primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Choisissez un jeu:",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Apprenez en vous amusant!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // CARTE TROUVEZ L'IMAGE
              _buildGameCard(
                context,
                "Trouvez l'image",
                "Trouvez l'image correspondante\nau mot proposé",
                Icons.image,
                lightRed,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindImageGame(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // CARTE ÉCRIVEZ LE MOT
              _buildGameCard(
                context,
                "Écrivez le mot",
                "Écrivez le mot correspondant\nau signe proposé",
                Icons.edit,
                lightRed,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WriteWordGamePage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // CARTE VIDÉO INTERACTIVE
              _buildGameCard(
                context,
                "Vidéo Interactive",
                "Apprenez avec des vidéos\ninteractives",
                Icons.play_circle,
                lightRed,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveVideoPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // CARTE RECONNAISSANCE IA
              _buildGameCard(
                context,
                "Reconnaissance IA",
                "Utilisez l'IA pour reconnaître\nvos signes en temps réel",
                Icons.camera_alt,
                lightRed,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIRecognitionPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // CARTE DICTIONNAIRE
              _buildGameCard(
                context,
                "Dictionnaire",
                "Consultez le dictionnaire\ncomplet des signes",
                Icons.menu_book,
                lightRed,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DictionaryPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
