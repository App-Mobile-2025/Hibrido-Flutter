import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountConfigSection extends StatelessWidget {
  const AccountConfigSection({super.key});

  User? get _user => FirebaseAuth.instance.currentUser;

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // --------- CERRAR SESIÓN ---------
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navegás al login y limpiás el stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Cerrar sesión'),
          content: const Text(
            'Vas a cerrar sesión en ReciclApp.\n\n'
            'Podés volver a iniciar sesión cuando quieras.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _signOut(context);
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  // --------- ELIMINAR CUENTA ---------
  Future<void> _deleteAccount(BuildContext context) async {
    final user = _user;
    if (user == null) {
      _showSnack(context, 'No hay sesión activa.');
      return;
    }

    try {
      await user.delete();

      // Después de borrar, vamos al login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showSnack(
          context,
          'Por seguridad, volvé a iniciar sesión para eliminar la cuenta.',
        );
      } else {
        _showSnack(context, 'No se pudo eliminar la cuenta: ${e.code}');
      }
    } catch (_) {
      _showSnack(context, 'Ocurrió un error al eliminar la cuenta.');
    }
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Eliminar cuenta'),
          content: const Text(
            'Esta acción eliminará tu cuenta de ReciclApp.\n\n'
            '- Podrías perder tu historial y puntos.\n'
            '- No se podrá recuperar la cuenta.\n\n'
            '¿Estás seguro que querés continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _deleteAccount(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
        children: [
          // --------- INFO DE LA CUENTA ----------
          ListTile(
            leading: const Icon(Icons.badge_outlined, color: Colors.green),
            title: const Text('Cuenta actual'),
            subtitle: Text(
              user?.email ?? 'Sesión anónima o sin email',
            ),
          ),
          if (user != null && user.uid.isNotEmpty) ...[
            ListTile(
              leading:
                  const Icon(Icons.fingerprint_outlined, color: Colors.grey),
              title: const Text('ID de usuario'),
              subtitle: Text(user.uid),
            ),
          ],
          const Divider(height: 0),

          // --------- CERRAR SESIÓN ----------
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Salir de tu cuenta en este dispositivo'),
            onTap: () => _confirmSignOut(context),
          ),
          const Divider(height: 0),

          // --------- ELIMINAR CUENTA ----------
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text(
              'Eliminar cuenta',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
            subtitle: const Text(
              'Eliminar tu cuenta de ReciclApp de forma permanente',
            ),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }
}
