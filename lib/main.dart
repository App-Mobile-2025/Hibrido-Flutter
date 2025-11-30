import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// TUS PANTALLAS
import 'package:reciclapp/ui/home/splash_screen.dart';
import 'package:reciclapp/ui/login/login_screen.dart';
import 'package:reciclapp/ui/home/home_screen.dart';
import 'package:reciclapp/ui/recycle_detail/recycle_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Reciclapp());
}

class Reciclapp extends StatelessWidget {
  const Reciclapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reciclapp - Híbrido',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      home: const SplashScreen(),

      routes: {
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),
        
        "/detalle_reciclaje": (context) {
          final docId = ModalRoute.of(context)!.settings.arguments as String;
          return RecycleDetailScreen(docId: docId);
        },


      },);
  }
}
