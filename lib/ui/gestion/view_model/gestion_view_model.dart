import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GestionViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool loadingPoints = false;
  int puntos = 0;

  bool loadingHistorial = false;
  List<DocumentSnapshot> historial = [];
  List<DocumentSnapshot> historialOriginal = [];

  final inputBuscar = TextEditingController();

  Future<void> cargarPuntos() async {
    loadingPoints = true;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _db.collection("users").doc(uid).get();
    puntos = (doc.data()?["puntos"] ?? 0) as int;

    loadingPoints = false;
    notifyListeners();
  }

  Future<void> cargarHistorial() async {
    loadingHistorial = true;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final result = await _db
        .collection("reciclajes")
        .where("uid", isEqualTo: uid)
        .get();

    final docs = result.docs;
    docs.sort((a, b) {
      final da = a.get("confirmedAt");
      final db = b.get("confirmedAt");
      return (db?.toDate() ?? DateTime(0))
          .compareTo(da?.toDate() ?? DateTime(0));
    });

    historial = docs;
    historialOriginal = List.from(docs);

    loadingHistorial = false;
    notifyListeners();
  }

  void buscarNota() {
    final texto = inputBuscar.text.trim();
    if (texto.isEmpty) {
      historial = List.from(historialOriginal);
    } else {
      historial = historialOriginal.where((doc) {
        final nota = (doc.get("nota") ?? "").toString().toLowerCase();
        return nota.contains(texto.toLowerCase());
      }).toList();
    }
    inputBuscar.clear();
    notifyListeners();
  }

  void aplicarFiltro(List<String> estados) {
    if (estados.isEmpty) {
      historial = List.from(historialOriginal);
    } else {
      historial = historialOriginal.where((doc) { 
        final estado = (doc.get("estado") ?? "").toString();
        return estados.contains(estado);
      }).toList();
    }
    notifyListeners();
  }
}

