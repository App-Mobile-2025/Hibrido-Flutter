import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReciclajeItem extends StatelessWidget {
  final DocumentSnapshot doc;
  final VoidCallback onTap;

  const ReciclajeItem({
    required this.doc,
    required this.onTap,
    super.key,
  });

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case "aprobado":
        return Colors.green.shade600;
      case "pendiente":
        return Colors.amber.shade700;
      case "rechazado":
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nota = doc.get("nota") ?? "Sin nota";
    final estado = doc.get("estado") ?? "Desconocido";
    final fecha = (doc.get("confirmedAt") as Timestamp?)?.toDate();

    final colorEstado = _colorEstado(estado);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),

        child: Row(
          children: [
            // Línea de estado
            Container(
              width: 6,
              height: 85,
              decoration: BoxDecoration(
                color: colorEstado,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icono
                    Icon(Icons.recycling, size: 32, color: colorEstado),

                    const SizedBox(width: 16),

                    // Texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nota,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            fecha != null
                                ? "${fecha.day}/${fecha.month}/${fecha.year}"
                                : "Sin fecha",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        estado.toUpperCase(),
                        style: TextStyle(
                          color: colorEstado,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
