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

  @override
  Widget build(BuildContext context) {
    final nota = doc.get("nota") ?? "";
    final estado = doc.get("estado") ?? "";
    final fecha = (doc.get("confirmedAt") as Timestamp?)?.toDate();

    return Card(
      child: ListTile(
        title: Text(nota),
        subtitle: Text("${estado} • ${fecha ?? ''}"),
        onTap: onTap,
      ),
    );
  }
}
