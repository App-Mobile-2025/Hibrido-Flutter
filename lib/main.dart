import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:reciclapp/ui/configuracion/provider/appearance_provider.dart';
import 'firebase_options.dart';

// PROVIDERS
import 'package:reciclapp/ui/configuracion/provider/language_provider.dart';
import 'package:reciclapp/ui/configuracion/provider/notification_provider.dart';

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
        ChangeNotifierProvider(create: (_) => AppearanceProvider()),
      ],
      child: const Reciclapp(),
    ),
  );
}

class Reciclapp extends StatelessWidget {
  const Reciclapp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final appearance = context.watch<AppearanceProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reciclapp - Híbrido',

      // Idioma
      locale: langProvider.language.locale,
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

       // Apariencia
  themeMode: appearance.flutterThemeMode,

  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light, 
    ),
    useMaterial3: true,
  ),

  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,  
    ),
    useMaterial3: true,
  ),

  builder: (context, child) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(appearance.textScale),
      ),
      child: child!,
    );
  },

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