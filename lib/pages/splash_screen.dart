import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'login_page.dart';
import 'home_page.dart';
import '../services/user_service.dart';

const Color primaryRed = Color(0xFFE60012);
const Color bgGrey = Color(0xFFF5F5F5);
const Color lightRed = Color(0xFFFFE5E5);
const Color mediumRed = Color(0xFFB32D2D);
const Color darkRed = Color(0xFF801818);
const Color lightRed2 = Color(0xFFCC0000);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _starController;
  late AnimationController _bounceController;

  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<double> _starRotation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _logoController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _textController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _starController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    _bounceController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _logoScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _starRotation = Tween(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _starController, curve: Curves.linear),
    );

    _bounceAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.bounceOut),
    );

    _startAnimations();
    _checkLoginAndNavigate();
  }

  void _startAnimations() {
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _starController.repeat();
      _bounceController.forward();
    });
  }

  Future<void> _checkLoginAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final isLoggedIn = await UserService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _starController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Widget buildStar(double size) {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _starRotation.value,
          child: Icon(
            Icons.star,
            color: primaryRed,
            size: size,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              lightRed.withOpacity(0.8),
              mediumRed.withOpacity(0.8),
              darkRed.withOpacity(0.6),
              lightRed2.withOpacity(0.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// STARS
              Expanded(
                flex: 2,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildStar(28),
                            const SizedBox(width: 10),
                            buildStar(40),
                            const SizedBox(width: 10),
                            buildStar(28),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// TEXT CARD
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textOpacity,
                      child: AnimatedBuilder(
                        animation: _bounceController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1 + (_bounceAnimation.value * 0.05),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 30),
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [

                                  Text(
                                    "LST Recognition",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: primaryRed,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    "Langue des Signes",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  SizedBox(height: 12),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.accessibility,
                                          color: Colors.black87),
                                      SizedBox(width: 6),
                                      Text(
                                        "Tunisie",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),

                                  Text(
                                    "Apprendre en s'amusant !",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: primaryRed,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    "Découvrez la langue des signes tunisienne",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  CircularProgressIndicator(
                                    color: primaryRed,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}