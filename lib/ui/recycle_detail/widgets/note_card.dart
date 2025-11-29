import 'package:flutter/material.dart';

class NoteCardWidget extends StatelessWidget {
  final String nota;

  const NoteCardWidget({super.key, required this.nota});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        width: double.infinity, 
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nota:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(nota, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
