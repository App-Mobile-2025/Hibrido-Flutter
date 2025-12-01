import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reciclapp/ui/configuracion/language_provider.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// PROVIDER E IDIOMA
import 'package:provider/provider.dart';

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

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const Reciclapp(),
    ),
  );
}

class Reciclapp extends StatelessWidget {
  const Reciclapp({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos el idioma actual del provider
    final lang = context.watch<LanguageProvider>().language;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reciclapp - Híbrido',

      // Idioma actual de la app
      locale: lang.locale,

      // Localizaciones básicas de Flutter (botones, fechas, etc.)
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
        Locale('pt'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

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
      },
    );
  }
}
