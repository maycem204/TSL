import 'package:flutter/material.dart';
import 'dart:math';

const Color primaryRed = Color(0xFFE60012);
const Color bgGrey = Color(0xFFF5F5F5);
const Color lightRed = Color(0xFFFFE5E5);
const Color mediumRed = Color(0xFFB32D2D);
const Color darkRed = Color(0xFF801818);
const Color lightRed2 = Color(0xFFCC0000);
const Color mediumRed2 = Color(0xFF990000);

class FindImageGame extends StatefulWidget {
  const FindImageGame({super.key});

  @override
  State<FindImageGame> createState() => _FindImageGameState();
}

class _FindImageGameState extends State<FindImageGame> with TickerProviderStateMixin {
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
  late List<String> _currentImages;
  late int _correctImageIndex;
  
  int _currentQuestionIndex = 0;
  int _totalXP = 0;
  int _correctAnswers = 0;
  bool _showResult = false;
  bool _isCorrect = false;
  int? _selectedImageIndex;
  bool _gameStarted = false;
  final Random _random = Random();
  
  late AnimationController _confettiController;
  late AnimationController _bounceController;
  late Animation<double> _confettiAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.elasticOut),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.bounceOut),
    );
    _initializeGame();
  }

  void _initializeGame() {
    final shuffledSigns = List<SignItem>.from(_allSigns)..shuffle(_random);
    _gameQuestions = shuffledSigns.take(6).toList();
  }

  void _startGame() {
    _confettiController.forward();
    _bounceController.forward();
    
    setState(() {
      _gameStarted = true;
      _currentQuestionIndex = 0;
      _totalXP = 0;
      _correctAnswers = 0;
      _showResult = false;
      _isCorrect = false;
      _selectedImageIndex = null;
      _initializeGame();
      _setupQuestion();
    });
  }

  void _setupQuestion() {
    final currentSign = _gameQuestions[_currentQuestionIndex];
    
    final List<SignItem> availableSigns = List.from(_allSigns);
    availableSigns.removeWhere((sign) => sign.word == currentSign.word);
    
    final randomSigns = List<SignItem>.from(availableSigns)..shuffle(_random);
    final selectedRandomSigns = randomSigns.take(3).toList();
    
    final List<SignItem> allOptions = [currentSign, ...selectedRandomSigns];
    allOptions.shuffle(_random);
    
    _correctImageIndex = allOptions.indexOf(currentSign);
    _currentImages = allOptions.map((sign) => sign.imagePath).toList();
    
    setState(() {
      _selectedImageIndex = null;
      _showResult = false;
    });
  }

  void _selectImage(int index) {
    if (_showResult) return;
    
    setState(() {
      _selectedImageIndex = index;
    });
  }

  void _checkAnswer() {
    if (_selectedImageIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner une image"),
          backgroundColor: primaryRed,
        ),
      );
      return;
    }

    setState(() {
      _showResult = true;
      _isCorrect = _selectedImageIndex == _correctImageIndex;

      if (_isCorrect) {
        _totalXP += 10;
        _correctAnswers++;
        _confettiController.forward(from: 0.0);
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

  void _nextQuestion() {
    _bounceController.forward(from: 0.0);
    
    setState(() {
      _currentQuestionIndex++;
      _setupQuestion();
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
              animation: _confettiController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_confettiAnimation.value * 0.3),
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
    if (percentage >= 80) return "Excellent! Vous maîtrisez parfaitement les signes!";
    if (percentage >= 60) return "Bon travail! Continuez à pratiquer!";
    if (percentage >= 40) return "Pas mal! Encore un peu d'entraînement.";
    return "Continuez à apprendre, vous allez y arriver!";
  }

  void _saveScoreToProfile() {
    print("Score Trouvez l'image sauvegardé: $_totalXP XP - $_correctAnswers/${_gameQuestions.length}");
    
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
    _confettiController.dispose();
    _bounceController.dispose();
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
          "Trouvez l'image",
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
                    animation: _confettiController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _confettiAnimation.value * 6.28,
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
                          colors: [primaryRed, lightRed2],
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
                            Icons.image,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Trouvez l'image correspondante!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "L'application va vous proposer un mot\net vous devez sélectionner la bonne image",
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
                                  "6 questions • 10 XP par bonne réponse",
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
                          colors: [mediumRed, mediumRed2],
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
              
              // Word to find
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryRed, lightRed2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Trouvez l'image pour:",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _gameQuestions[_currentQuestionIndex].word,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Image grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                itemCount: _currentImages.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedImageIndex == index;
                  final isCorrect = _showResult && index == _correctImageIndex;
                  final isWrong = _showResult && isSelected && index != _correctImageIndex;
                  
                  return GestureDetector(
                    onTap: () => _selectImage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                            ? (isCorrect ? lightRed : (isWrong ? darkRed : lightRed))
                            : Colors.black26,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                              ? (isCorrect ? primaryRed.withOpacity(0.3) : (isWrong ? primaryRed.withOpacity(0.2) : primaryRed.withOpacity(0.3)))
                              : Colors.black.withOpacity(0.1),
                            blurRadius: isSelected ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isSelected 
                            ? (isCorrect ? lightRed : (isWrong ? darkRed : lightRed))
                            : Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              // Placeholder image (since we don't have actual assets)
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.black12,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.black38,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Image ${index + 1}",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Overlay for correct/wrong answers
                              if (_showResult && index == _correctImageIndex)
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: primaryRed.withOpacity(0.3),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: primaryRed,
                                    size: 40,
                                  ),
                                ),
                              if (_showResult && isSelected && index != _correctImageIndex)
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: primaryRed.withOpacity(0.3),
                                  child: const Icon(
                                    Icons.cancel,
                                    color: primaryRed,
                                    size: 40,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              // Action buttons
              if (!_showResult) ...[
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _selectedImageIndex != null ? _checkAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedImageIndex != null ? primaryRed : Colors.black26,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: const Text(
                      "Valider ma réponse",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCorrect ? primaryRed.withOpacity(0.1) : primaryRed.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isCorrect ? primaryRed : primaryRed.withOpacity(0.7),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect ? primaryRed : primaryRed.withOpacity(0.7),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCorrect ? "Correct! +10 XP" : "Incorrect! Essayez encore",
                        style: TextStyle(
                          color: _isCorrect ? primaryRed : primaryRed.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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