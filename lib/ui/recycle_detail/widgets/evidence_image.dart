import 'dart:typed_data';
import 'package:flutter/material.dart';

class EvidenceImageWidget extends StatelessWidget {
  final Uint8List? imageBytes;

  const EvidenceImageWidget({super.key, this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageBytes != null
          ? Image.memory(
              imageBytes!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Text("Sin imagen"),
            ),
    );
  }
}
