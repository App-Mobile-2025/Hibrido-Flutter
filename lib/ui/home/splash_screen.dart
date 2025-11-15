import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController fadeCtrl;

  @override
  void initState() {
    super.initState();

    // Animación fade-in
    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      fadeCtrl.forward();
    });

    // Después de 3 segundos → LOGIN
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  void dispose() {
    fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4CAF50),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Animación Lottie
            SizedBox(
              height: 220,
              child: Lottie.asset(
                "assets/reciclaje.json",
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // Fade-in TÍTULO
            FadeTransition(
              opacity: fadeCtrl,
              child: const Text(
                "ReciclApp",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Fade-in autores
            FadeTransition(
              opacity: fadeCtrl,
              child: const Text(
                "Desarrollado por Fiorrela, Enzo y Julieta",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
