import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'dart:math';

const Color primaryRed = Color(0xFFE60012);
const Color bgGrey = Color(0xFFF5F5F5);
const Color lightRed = Color(0xFFFFE5E5);
const Color mediumRed = Color(0xFFB32D2D);
const Color darkRed = Color(0xFF801818);
const Color lightRed2 = Color(0xFFCC0000);
const Color mediumRed2 = Color(0xFF990000);
const Color successGreen = Color(0xFF4CAF50);
const Color errorOrange = Color(0xFFFF9800);

class FindImageGame extends StatefulWidget {
  const FindImageGame({super.key});

  @override
  State<FindImageGame> createState() => _FindImageGameState();
}

class _FindImageGameState extends State<FindImageGame> {
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

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final shuffledSigns = List<SignItem>.from(_allSigns)..shuffle(_random);
    _gameQuestions = shuffledSigns.take(6).toList();
  }

  void _startGame() {
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
            Icon(
              _totalXP >= 40 ? Icons.emoji_events : _totalXP >= 20 ? Icons.star : Icons.star_outline,
              size: 60,
              color: _totalXP >= 40 ? primaryRed : _totalXP >= 20 ? primaryRed.withOpacity(0.7) : primaryRed,
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

  void _saveScoreToProfile() async {
    print("Score Trouvez l'image sauvegardé: $_totalXP XP - $_correctAnswers/${_gameQuestions.length}");
    
    // Ajouter les XP au backend
    final result = await UserService.addXP(_totalXP);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true 
              ? "Score de $_totalXP XP sauvegardé dans votre profil! Niveau: ${result['level']}"
              : "Erreur lors de la sauvegarde: ${result['message']}"
          ),
          backgroundColor: result['success'] == true ? primaryRed : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
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
                  const Icon(
                    Icons.star,
                    color: primaryRed,
                    size: 20,
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
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Trouvez l'image correspondante!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "L'application va vous proposer un mot\net vous devez sélectionner la bonne image",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "6 questions • 10 XP par bonne réponse",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryRed,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Maximum: 60 XP",
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
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
              ),
            ] else ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryRed,
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
              const SizedBox(height: 20),
              
              // Word to find
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      "Trouvez l'image pour:",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _gameQuestions[_currentQuestionIndex].word,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                    child: Container(
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
                              // Placeholder image
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.black.withOpacity(0.08),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 40,
                                      color: isSelected 
                                        ? (isCorrect ? primaryRed : (isWrong ? darkRed : primaryRed))
                                        : Colors.black38,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Image ${index + 1}",
                                      style: TextStyle(
                                        color: isSelected 
                                          ? (isCorrect ? primaryRed : (isWrong ? darkRed : primaryRed))
                                          : Colors.black54,
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
                                  color: successGreen.withOpacity(0.2),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: successGreen,
                                        size: 50,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Correct!",
                                        style: TextStyle(
                                          color: successGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_showResult && isSelected && index != _correctImageIndex)
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: errorOrange.withOpacity(0.2),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cancel,
                                        color: errorOrange,
                                        size: 50,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Incorrect!",
                                        style: TextStyle(
                                          color: errorOrange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
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
                    color: _isCorrect ? successGreen.withOpacity(0.1) : errorOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isCorrect ? successGreen : errorOrange,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isCorrect ? successGreen : errorOrange).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect ? successGreen : errorOrange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCorrect ? "Correct! +10 XP" : "Essayez encore!",
                        style: TextStyle(
                          color: _isCorrect ? successGreen : errorOrange,
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