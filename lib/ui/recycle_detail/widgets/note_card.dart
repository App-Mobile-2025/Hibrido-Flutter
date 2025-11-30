import 'package:flutter/material.dart';

class NoteCardWidget extends StatelessWidget {
  final String nota;
  final VoidCallback onEdit;

  const NoteCardWidget({
    super.key,
    required this.nota,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Nota:", style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(nota, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
