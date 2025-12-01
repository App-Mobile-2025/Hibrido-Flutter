import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reciclapp/ui/configuracion/language_provider.dart';
import 'package:reciclapp/ui/configuracion/notification_provider.dart';
import 'package:reciclapp/ui/configuracion/appearance_provider.dart';
// agregá url_launcher en pubspec y descomentá:
// import 'package:url_launcher/url_launcher.dart';

class LegalConfigSection extends StatelessWidget {
  const LegalConfigSection({super.key});

  // --------- abrir links externos ----------
  Future<void> _openUrl(String url) async {
    // final uri = Uri.parse(url);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri, mode: LaunchMode.externalApplication);
    // }
  }

  void _resetApp(BuildContext context) {
    // Resetear idioma
    final langProvider = context.read<LanguageProvider>();
    langProvider.setLanguage(AppLanguage.es); // por defecto ES

    // Resetear notificaciones
    final notifProvider = context.read<NotificationSettingsProvider>();
    notifProvider.setNotificationsEnabled(true);
    notifProvider.setPointsReminderEnabled(true);

    // Resetear apariencia
    final appearanceProvider = context.read<AppearanceProvider>();
    appearanceProvider.setThemeMode(AppThemeMode.system);
    appearanceProvider.setTextScale(1.0);
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Resetear aplicación'),
          content: const Text(
            'Esto va a restaurar algunas configuraciones de ReciclApp a sus valores por defecto '
            '(idioma, notificaciones, apariencia).\n\n'
            '¿Querés continuar?',
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
              onPressed: () {
                Navigator.of(ctx).pop();
                _resetApp(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración restablecida correctamente'),
                  ),
                );
              },
              child: const Text('Resetear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            const Icon(Icons.privacy_tip_outlined, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Privacidad y términos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
        children: [
          // --------- Política de privacidad ----------
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.green),
            title: const Text('Política de privacidad'),
            subtitle: const Text('Cómo manejamos tus datos en ReciclApp'),
            onTap: () {
              _openUrl('https://tusitio.com/politica-privacidad');
            },
          ),
          const Divider(height: 0),

          // --------- Términos y condiciones ----------
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.green),
            title: const Text('Términos y condiciones'),
            subtitle: const Text('Condiciones de uso de ReciclApp'),
            onTap: () {
              _openUrl('https://tusitio.com/terminos-condiciones');
            },
          ),
          const Divider(height: 0),

          // --------- Resetear app ----------
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.redAccent),
            title: const Text(
              'Resetear app',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Restablecer configuraciones a los valores por defecto',
            ),
            onTap: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }
}
