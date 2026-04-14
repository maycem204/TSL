import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'dart:math';

const Color primaryRed = Color(0xFFE60012);
const Color bgGrey = Color(0xFFF5F5F5);
const Color lightPink = Color(0xFFFBEDED);

class SignItem {
  final String word;
  final String imagePath;

  SignItem({
    required this.word,
    required this.imagePath,
  });
}

class FindImageGameTest extends StatefulWidget {
  const FindImageGameTest({super.key});

  @override
  State<FindImageGameTest> createState() => _FindImageGameTestState();
}

class _FindImageGameTestState extends State<FindImageGameTest> {
  late List<SignItem> _gameQuestions;
  late List<String> _currentImages;
  late int _correctImageIndex;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  bool _showResult = false;
  bool _isCorrect = false;
  int? _selectedImageIndex;
  bool _gameStarted = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Ne pas initialiser ici, laisser _startGame choisir aléatoirement
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _currentQuestionIndex = 0;
      _correctAnswers = 0;
      _showResult = false;
      _isCorrect = false;
      _selectedImageIndex = null;
      
      // Utiliser une nouvelle graine aléatoire basée sur le temps pour un vrai aléatoire
      final randomWithSeed = Random(DateTime.now().millisecondsSinceEpoch);
      final shuffledSigns = List<SignItem>.from(_allSigns)..shuffle(randomWithSeed);
      _gameQuestions = shuffledSigns.take(6).toList();
      
      _setupQuestion();
    });
  }

  void _setupQuestion() {
    final questionSign = _gameQuestions[_currentQuestionIndex];
    
    // Créer une liste de toutes les options sauf la bonne réponse
    final otherOptions = _allSigns.where((sign) => sign.word != questionSign.word).toList();
    
    // Utiliser une graine aléatoire différente pour les options
    final optionsRandom = Random(DateTime.now().millisecondsSinceEpoch + _currentQuestionIndex + 100);
    otherOptions.shuffle(optionsRandom);
    final randomOptions = otherOptions.take(3).toList();
    
    // Ajouter la bonne réponse et mélanger les 4 options avec une autre graine
    final allOptions = [questionSign, ...randomOptions];
    final finalRandom = Random(DateTime.now().millisecondsSinceEpoch + _currentQuestionIndex + 200);
    allOptions.shuffle(finalRandom);
    
    _correctImageIndex = allOptions.indexOf(questionSign);
    _currentImages = allOptions.map((sign) => sign.imagePath).toList();
    
    setState(() {
      _selectedImageIndex = null;
      _showResult = false;
      _isCorrect = false;
    });
  }

  void _selectImage(int index) {
    if (_showResult || _selectedImageIndex != null) return;
    
    setState(() {
      _selectedImageIndex = index;
    });
  }

  void _checkAnswer() {
    if (_selectedImageIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.sentiment_dissatisfied, color: Colors.white),
              const SizedBox(width: 8),
              const Text("Veuillez sélectionner une image"),
            ],
          ),
          backgroundColor: primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isCorrect = _selectedImageIndex == _correctImageIndex;
    
    setState(() {
      _showResult = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _correctAnswers++;
    }

    _saveScoreToProfile();

    // Passer automatiquement à la question suivante après 1.5 secondes
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_currentQuestionIndex < _gameQuestions.length - 1) {
          _nextQuestion();
        } else {
          _showFinalScore();
        }
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _gameQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedImageIndex = null;
        _showResult = false;
        _isCorrect = false;
      });
      _setupQuestion();
    } else {
      _showFinalScore();
    }
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryRed,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$_correctAnswers/${_gameQuestions.length}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Score",
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Test terminé avec succès!",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Retour",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _saveScoreToProfile() {
    print('💾 Score sauvegardé: $_correctAnswers/${_gameQuestions.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Test Jeu (Sans XP)",
          style: TextStyle(
            color: primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryRed),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
            const Text(
              "Test du jeu Trouvez l'image",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 20),
            if (!_gameStarted)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Commencer",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            if (_gameStarted && !_showResult)
              Column(
                children: [
                  Text(
                    "Question ${_currentQuestionIndex + 1}/${_gameQuestions.length}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Trouvez l'image pour: ${_gameQuestions[_currentQuestionIndex].word}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _currentImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _selectImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedImageIndex == index ? primaryRed : Colors.grey.withOpacity(0.3),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  _currentImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Image non trouvée',
                                            style: TextStyle(color: Colors.grey, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (_showResult && index == _correctImageIndex)
                                const Icon(Icons.check_circle, color: Colors.green, size: 20)
                              else if (_showResult && index == _selectedImageIndex && index != _correctImageIndex)
                                const Icon(Icons.cancel, color: Colors.red, size: 20),
                            ],
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedImageIndex != null ? primaryRed : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _selectedImageIndex != null ? "Valider" : "Sélectionnez une image",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
            ),
            if (_showResult)
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 60,
                    color: _isCorrect ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCorrect ? "Correct !" : "Incorrect !",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "La bonne réponse était: ${_gameQuestions[_currentQuestionIndex].word}",
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < _gameQuestions.length - 1) {
                      _nextQuestion();
                    } else {
                      _showFinalScore();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _isCorrect ? "Suivant" : "Terminer",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
