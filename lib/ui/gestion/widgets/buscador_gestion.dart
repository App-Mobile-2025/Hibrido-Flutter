import 'package:flutter/material.dart';

class BuscadorGestion extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const BuscadorGestion({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Buscar por nota...",
        prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green.shade600),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
