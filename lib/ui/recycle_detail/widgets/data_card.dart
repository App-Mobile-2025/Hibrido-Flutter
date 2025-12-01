import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataCardWidget extends StatelessWidget {
  final String estado;
  final int puntos;
  final Timestamp? fechaTimestamp;
  final List<String> tags;
  final String materiales;

  const DataCardWidget({
    super.key,
    required this.estado,
    required this.puntos,
    required this.fechaTimestamp,
    required this.tags,
    required this.materiales,
  });

  Color getEstadoColor() {
    switch (estado.toUpperCase()) {
      case "APROBADO":
        return Colors.green.shade600;
      case "PENDIENTE":
        return Colors.orange.shade600;
      case "RECHAZADO":
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  Color _randomColor(String tag) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
    ];
    return colors[tag.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final fecha = fechaTimestamp?.toDate();
    final formattedDate = fecha != null
        ? "${fecha.day}/${fecha.month}/${fecha.year}"
        : "Sin fecha";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Column de materiales, tags y fecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado
                  Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: getEstadoColor(),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Fecha
                  Text(
                    "Fecha: $formattedDate",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Materiales
                  Text("Materiales:", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    materiales,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),

                  // Tags
                  Text("Tags:", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4, 
                    runSpacing: 4, 
                    children: tags.map((tag) {
                      final color = _randomColor(tag);
                      return Chip(
                        label: Text(
                          tag,
                          style: TextStyle(
                            color: color,
                            fontSize: 12, 
                          ),
                        ),
                        backgroundColor: color.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
                      );
                    }).toList(),
                  ),

                ],
              ),
            ),

            // Puntos
            Column(
              children: [
                Text("Puntos", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("+$puntos", style: const TextStyle(fontSize: 16, color: Colors.black)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
