import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      if (mounted) fadeCtrl.forward();
    });

    // ESTA FUNCIÓN DECIDE HOME o LOGIN
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Tiempo para mostrar el splash 
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // YA ESTÁ LOGUEADO → va DIRECTO al HOME
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      // NO ESTÁ LOGUEADO → va al LOGIN
      Navigator.pushReplacementNamed(context, "/login");
    }
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

            // Fade-in título
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
                "Desarrollado por Fiorela, Enzo y Julia",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Spinner
            FadeTransition(
              opacity: fadeCtrl,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
