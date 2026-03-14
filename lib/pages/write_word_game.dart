import 'package:flutter/material.dart';
import 'dart:math';

const Color primaryRed = Color(0xFFE60012);
const Color bgGrey = Color(0xFFF5F5F5);
const Color lightRed = Color(0xFFFFE5E5);
const Color mediumRed = Color(0xFFB32D2D);
const Color darkRed = Color(0xFF801818);
const Color lightRed2 = Color(0xFFCC0000);
const Color mediumRed2 = Color(0xFF990000);

class WriteWordGamePage extends StatefulWidget {
  const WriteWordGamePage({super.key});

  @override
  State<WriteWordGamePage> createState() => _WriteWordGamePageState();
}

class _WriteWordGamePageState extends State<WriteWordGamePage> with TickerProviderStateMixin {
  final List<SignItem> _allSigns = [
    SignItem(word: "Bonjour", imagePath: "assets/images/signs/bonjour.png"),
    SignItem(word: "Merci", imagePath: "assets/images/signs/merci.png"),
    SignItem(word: "Au revoir", imagePath: "assets/images/signs/aurevoir.png"),
    SignItem(word: "S'il vous plaît", imagePath: "assets/images/signs/silvousplait.png"),
    SignItem(word: "Comment allez-vous?", imagePath: "assets/images/signs/comment.png"),
    SignItem(word: "Je t'aime", imagePath: "assets/images/signs/jtaime.png"),
    SignItem(word: "Excusez-moi", imagePath: "assets/images/signs/excusezmoi.png"),
    SignItem(word: "Oui", imagePath: "assets/images/signs/oui.png"),
    SignItem(word: "Non", imagePath: "assets/images/signs/non.png"),
    SignItem(word: "Aidez-moi", imagePath: "assets/images/signs/aidezmoi.png"),
  ];

  late List<SignItem> _gameQuestions;
  int _currentQuestionIndex = 0;
  int _totalXP = 0;
  int _correctAnswers = 0;
  bool _gameStarted = false;
  final Random _random = Random();
  
  late AnimationController _bounceController;
  late AnimationController _sparkleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.bounceOut),
    );
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    _initializeGame();
  }

  void _initializeGame() {
    final shuffledSigns = List<SignItem>.from(_allSigns)..shuffle(_random);
    _gameQuestions = shuffledSigns.take(6).toList();
  }

  void _startGame() {
    _bounceController.forward();
    _sparkleController.forward();
    
    setState(() {
      _gameStarted = true;
      _currentQuestionIndex = 0;
      _totalXP = 0;
      _correctAnswers = 0;
      _initializeGame();
    });
  }

  void _nextQuestion() {
    _bounceController.forward(from: 0.0);
    
    setState(() {
      _currentQuestionIndex++;
    });
  }

  void _checkAnswer(String userAnswer) {
    final correctAnswer = _gameQuestions[_currentQuestionIndex].word.toLowerCase();
    final isCorrect = userAnswer.toLowerCase().trim() == correctAnswer || 
                    correctAnswer.contains(userAnswer.toLowerCase().trim()) || 
                    userAnswer.toLowerCase().trim().contains(correctAnswer);

    setState(() {
      if (isCorrect) {
        _totalXP += 10;
        _correctAnswers++;
        _sparkleController.forward(from: 0.0);
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestionIndex < _gameQuestions.length - 1) {
          _nextQuestion();
        } else {
          _showFinalScore();
        }
      }
    });
  }

  void _showFinalScore() {
    _saveScoreToProfile();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Partie terminée!",
          style: TextStyle(
            color: primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_sparkleAnimation.value * 0.3),
                  child: Icon(
                    _totalXP >= 40 ? Icons.emoji_events : _totalXP >= 20 ? Icons.star : Icons.star_outline,
                    size: 60,
                    color: _totalXP >= 40 ? primaryRed : _totalXP >= 20 ? primaryRed.withOpacity(0.7) : primaryRed,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              "$_totalXP XP",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$_correctAnswers/${_gameQuestions.length} réponses correctes",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPerformanceMessage(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text(
              "Rejouer",
              style: TextStyle(color: primaryRed),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Quitter"),
          ),
        ],
      ),
    );
  }

  String _getPerformanceMessage() {
    final percentage = (_correctAnswers / _gameQuestions.length) * 100;
    if (percentage >= 80) return "Excellent! Vous écrivez parfaitement les mots!";
    if (percentage >= 60) return "Bon travail! Continuez à pratiquer l'écriture!";
    if (percentage >= 40) return "Pas mal! Encore un peu d'entraînement.";
    return "Continuez à apprendre, vous allez y arriver!";
  }

  void _saveScoreToProfile() {
    print("Score Écrivez le mot sauvegardé: $_totalXP XP - $_correctAnswers/${_gameQuestions.length}");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Score de $_totalXP XP sauvegardé dans votre profil!"),
        backgroundColor: primaryRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Écrivez le mot",
          style: TextStyle(
            color: primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_gameStarted)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _sparkleController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _sparkleAnimation.value * 6.28,
                        child: const Icon(
                          Icons.star,
                          color: primaryRed,
                          size: 20,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "$_totalXP XP",
                    style: const TextStyle(
                      color: primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!_gameStarted) ...[
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_bounceAnimation.value * 0.2),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mediumRed, mediumRed2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Écrivez le mot correspondant!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "L'application va vous montrer des signes aléatoires\net vous devez écrire le mot correspondant",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  "6 exercices • 10 XP par bonne réponse",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryRed,
                                  ),
                                ),
                                Text(
                                  "Maximum: 60 XP",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_bounceAnimation.value * 0.1),
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text(
                          "Commencer le jeu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_bounceAnimation.value * 0.05),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mediumRed, darkRed],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "Question ${_currentQuestionIndex + 1}/${_gameQuestions.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_bounceAnimation.value * 0.05),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, mediumRed2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Quel est ce mot?",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [mediumRed2, mediumRed2.withOpacity(0.3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sign_language,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            onChanged: (value) => _checkAnswer(value),
                            onSubmitted: (value) => _checkAnswer(value),
                            decoration: InputDecoration(
                              hintText: "Écrivez votre réponse...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.edit, color: primaryRed),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _checkAnswer(""),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor: Colors.black.withOpacity(0.2),
                              ),
                              child: const Text(
                                "Valider (+10 XP)",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class SignItem {
  final String word;
  final String imagePath;

  SignItem({
    required this.word,
    required this.imagePath,
  });
}
