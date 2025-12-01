import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoSection extends StatefulWidget {
  const AppInfoSection({super.key});

  @override
  State<AppInfoSection> createState() => _AppInfoSectionState();
}

class _AppInfoSectionState extends State<AppInfoSection> {
  String version = "Cargando...";

  bool serverOnline = true; 

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = "${info.version} (${info.buildNumber})";
    });
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
            const Icon(Icons.info_outline, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Información de la app',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),

        children: [
          //
          // ---------- VERSIÓN ----------
          //
          ListTile(
            leading: const Icon(Icons.tag, color: Colors.green),
            title: const Text("Versión de ReciclApp"),
            subtitle: Text(version),
          ),
          const Divider(height: 0),

          //
          // ---------- ESTADO DEL SERVIDOR ----------
          //
          ListTile(
            leading: Icon(
              serverOnline ? Icons.cloud_done : Icons.cloud_off,
              color: serverOnline ? Colors.green : Colors.red,
            ),
            title: const Text("Estado del servidor"),
            subtitle: Text(serverOnline ? "Online" : "Offline"),
            trailing: Icon(
              serverOnline ? Icons.check_circle : Icons.error,
              color: serverOnline ? Colors.green : Colors.red,
            ),
            onTap: () {
            },
          ),
          const Divider(height: 0),

          //
          // ---------- CHANGELOG / NOVEDADES ----------
          //
          ListTile(
            leading: const Icon(Icons.new_releases, color: Colors.green),
            title: const Text("Novedades / Changelog"),
            subtitle: const Text("Ver últimos cambios y actualizaciones"),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text("Novedades de ReciclApp"),
                    content: const Text(
                      "- Nueva opcion de Notificaciones.\n"
                      "- Nueva opcion de Apariencia.\n"
                      "- Notificaciones BETA mejoradas.\n"
                      "- Mejoras de rendimiento.\n"
                      "- Correcciones varias.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text("Cerrar"),
                      )
                    ],
                  );
                },
              );
            },
          ),
          const Divider(height: 0),

          //
          // ---------- FAQ ----------
          //
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.green),
            title: const Text("Preguntas frecuentes (FAQ)"),
            subtitle: const Text("Respuestas a dudas comunes"),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text("Preguntas frecuentes"),
                    content: const Text(
                      "1) ¿Cómo registro un residuo?\n"
                      "→ Desde la pestaña de registro.\n\n"
                      "2) ¿Pierdo mis puntos?\n"
                      "→ No, solo vencen si no los usás.\n\n"
                      "3) ¿Qué es Mundito?\n"
                      "→ Es nuestra IA ecológica 🤖🌱.\n\n"
                      "4) ¿Otras dudas?\n"
                      "→ Utiliza a nuestro gran amigo el Bot mundito ,es capaz de resolver todas tus dudas ;).",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text("Cerrar"),
                      )
                    ],
                  );
                },
              );
            },
          ),
          const Divider(height: 0),

          //
          // ---------- CONTACTO ----------
          //
          ListTile(
            leading: const Icon(Icons.mail_outline, color: Colors.green),
            title: const Text("Contacto"),
            subtitle: const Text("Escribinos tu consulta o sugerencia"),
            onTap: () {
              // Abrir email
            },
          ),
          const Divider(height: 0),

          //
          // ---------- REPORTAR PROBLEMA ----------
          //
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.redAccent),
            title: const Text("Reportar un problema"),
            subtitle: const Text("Informar errores o fallas en la app"),
            onTap: () {
              _showReportDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Reportar un problema"),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Describí el problema...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();

                if (text.isNotEmpty) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text("Enviar"),
            ),
          ],
        );
      },
    );
  }
}
