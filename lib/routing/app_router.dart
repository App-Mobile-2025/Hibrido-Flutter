import 'package:flutter/material.dart';
import '../ui/home/home_screen.dart';
import '../ui/login/login_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/recycle_detail/recycle_detail_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/recyclingDetail':
        final docId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => RecycleDetailScreen(docId: docId),
        );

        
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
