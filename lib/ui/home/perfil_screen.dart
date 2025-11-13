import 'package:flutter/material.dart';
import 'package:reciclapp/data/services/auth_service.dart';
import 'package:reciclapp/ui/login/login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            "Mi Perfil",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: () async {
              await authService.logout();

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text("Cerrar sesión"),
          )
        ],
      ),
    );
  }
}
