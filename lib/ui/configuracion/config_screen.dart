import 'package:flutter/material.dart';
import 'package:reciclapp/ui/configuracion/widgets/account_section.dart';
import 'package:reciclapp/ui/configuracion/widgets/app_info_section.dart';

// Secciones
import 'package:reciclapp/ui/configuracion/widgets/appearance_section.dart';
import 'package:reciclapp/ui/configuracion/widgets/language_section.dart';
import 'package:reciclapp/ui/configuracion/widgets/legal_section.dart';
import 'package:reciclapp/ui/configuracion/widgets/notifications_section.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 8),
          Text(
            'Configuración',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 16),
          LanguageConfigSection(),
          SizedBox(height: 16),
          NotificationsConfigSection(),
          SizedBox(height: 16),
          AppearanceConfigSection(),
          SizedBox(height: 16),
          AppInfoSection(),
          SizedBox(height: 16),
          LegalConfigSection(),
          SizedBox(height: 16),
          AccountConfigSection(),

        ],
      ),
    );
  }
}
