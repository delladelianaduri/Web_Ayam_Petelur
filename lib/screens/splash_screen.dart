import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Color Scheme
  final Color _primaryColor = const Color(0xFF2E7D32);
  final Color _lightGreen = const Color(0xFF81C784);
  final Color _textColor = const Color(0xFF1B5E20);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  // Animation Controllers
  double _opacity = 0.0;
  double _scale = 0.9;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Start fade and scale animations after 200ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToOnboarding();
      }
    });
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const OnboardingScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Color _withAlpha(Color color, int alpha) => color.withAlpha(alpha);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 1000),
                scale: _scale,
                curve: Curves.easeOutBack,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _withAlpha(_primaryColor, 15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _withAlpha(_primaryColor, 30),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.egg_alt,
                        size: 64,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      "LAYER LINK",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                        letterSpacing: 1.8,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Connected Farm Technology",
                      style: TextStyle(
                        fontSize: 16,
                        color: _withAlpha(_textColor, 160),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 1200),
              opacity: _opacity,
              child: SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor: _withAlpha(_lightGreen, 40),
                    color: _primaryColor,
                    minHeight: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
