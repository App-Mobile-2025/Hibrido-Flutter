import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class RecycleDetailViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  bool loading = false;
  Map<String, dynamic>? data;
  Uint8List? evidenceBytes;

  late String docId;

  Future<void> load(String id) async {
    docId = id;
    loading = true;
    notifyListeners();

    try {
      final doc = await _db.collection("reciclajes").doc(docId).get();

      if (!doc.exists) {
        loading = false;
        notifyListeners();
        return;
      }

      data = doc.data();
      await _loadEvidenceImage();
    } catch (e) {
      debugPrint("ERROR loading detail: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _loadEvidenceImage() async {
    try {
      final evidenciaRefId = data?["evidenciaRefId"];
      if (evidenciaRefId == null) return;

      final evDoc =
          await _db.collection("evidencias").doc(evidenciaRefId).get();

      final url = evDoc["url"];
      final ref = _storage.refFromURL(url);
      evidenceBytes = await ref.getData(5 * 1024 * 1024);
    } catch (e) {
      debugPrint("ERROR loading image: $e");
    }
  }

  Future<void> updateNota(String nuevaNota) async {
    try {
      await _db.collection("reciclajes").doc(docId).update({
        "nota": nuevaNota,
      });

      data?["nota"] = nuevaNota;
      notifyListeners();
    } catch (e) {
      debugPrint("ERROR updating note: $e");
    }
  }

  void showEditNoteDialog(BuildContext context) {
    final controller = TextEditingController(text: data?["nota"] ?? "");

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Editar Nota"),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Escribe la nueva nota...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevaNota = controller.text.trim();
                await updateNota(nuevaNota);
                Navigator.pop(context);
                Navigator.pop(context, "updated");
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteReciclaje(BuildContext context) async {
    try {
      final evidenciaRefId = data?["evidenciaRefId"];

      // Si existe evidencia, borramos primero la imagen física
      if (evidenciaRefId != null) {
        final evDoc = await _db.collection("evidencias").doc(evidenciaRefId).get();

        if (evDoc.exists) {
          final url = evDoc["url"];
          final ref = _storage.refFromURL(url);

          // Borra archivo del storage
          await ref.delete();

          // Borra documento evidencia
          await _db.collection("evidencias").doc(evidenciaRefId).delete();
        }
      }

      // Borra el reciclaje
      await _db.collection("reciclajes").doc(docId).delete();

      // Volver avisando que se borró
      Navigator.pop(context, true);

    } catch (e) {
      debugPrint("Error deleting reciclaje: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar: $e")),
      );
    }
  }


  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Eliminar reciclaje"),
          content: const Text("¿Estás seguro de que querés eliminar este registro?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx); // cierro diálogo
                deleteReciclaje(context);
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

}
