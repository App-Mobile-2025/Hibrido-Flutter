import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// PROVIDERS
import 'package:reciclapp/ui/configuracion/language_provider.dart';
import 'package:reciclapp/ui/configuracion/notification_provider.dart';

// NOTIFICATION SERVICE
import 'package:reciclapp/data/services/notification_service.dart';

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

  // Inicializar notificaciones locales
  await NotificationService().init();
  await NotificationService().requestAndroidPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
      ],
      child: const Reciclapp(),
    ),
  );
}

class Reciclapp extends StatelessWidget {
  const Reciclapp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reciclapp - Híbrido',
      locale: lang.locale,
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
