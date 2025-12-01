import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reciclapp/ui/configuracion/provider/notification_provider.dart';

class NotificationsConfigSection extends StatelessWidget {
  const NotificationsConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationSettingsProvider>();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
        title: Row(
          children: [
            Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message:
                  'Función en desarrollo. Puede cambiar o mejorar en futuras versiones.',
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: const [
                            Icon(Icons.flash_on, size: 20),
                            SizedBox(width: 8),
                            Text('Notificaciones (BETA)'),
                          ],
                        ),
                        content: const Text(
                          'Esta sección de notificaciones todavía está en fase BETA.\n\n'
                          '- La configuración puede cambiar en futuras versiones.\n'
                          '- Podrían agregarse nuevos tipos de avisos.\n'
                          '- Si algo no funciona como esperás, ¡contanos tu opinión!',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.flash_on, size: 12, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'BETA',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        children: [
          SwitchListTile(
            value: notif.notificationsEnabled,
            onChanged: (value) {
              notif.setNotificationsEnabled(value);
            },
            title: const Text(
              'Notificaciones generales',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Activar o desactivar todos los avisos de ReciclApp.',
            ),
            activeThumbColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
          ),
          const Divider(height: 0),
          SwitchListTile(
            value: notif.pointsReminderEnabled,
            onChanged: notif.notificationsEnabled
                ? (value) {
                    notif.setPointsReminderEnabled(value);
                  }
                : null,
            title: const Text(
              'Recordatorios de puntos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Te avisamos cuando podés canjear puntos o se acercan a la fecha de vencimiento.',
            ),
            activeThumbColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Podés desactivar los recordatorios de puntos sin perder tu saldo acumulado.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
