import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reciclapp/ui/configuracion/language_provider.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Idioma de la aplicación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Column(
              children: [
                _LanguageTile(
                  value: AppLanguage.es,
                  groupValue: lang,
                  description: 'Español (Argentina)',
                ),
                const Divider(height: 0),
                _LanguageTile(
                  value: AppLanguage.en,
                  groupValue: lang,
                  description: 'English (US)',
                ),
                const Divider(height: 0),
                _LanguageTile(
                  value: AppLanguage.pt,
                  groupValue: lang,
                  description: 'Português (BR)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'El idioma se aplicará en todas las pantallas compatibles. '
            'Algunas secciones pueden seguir apareciendo en español si aún no fueron traducidas.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage value;
  final AppLanguage groupValue;
  final String description;

  const _LanguageTile({
    required this.value,
    required this.groupValue,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LanguageProvider>();

    return RadioListTile<AppLanguage>(
      value: value,
      groupValue: groupValue,
      onChanged: (v) {
        if (v != null) {
          provider.setLanguage(v);
        }
      },
      title: Text(
        '${value.flag}  ${value.label}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(description),
      activeColor: Colors.green,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
