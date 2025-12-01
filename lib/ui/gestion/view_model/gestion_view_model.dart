import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:reciclapp/data/services/notification_service.dart';
import 'package:reciclapp/ui/configuracion/provider/notification_provider.dart';
import 'package:reciclapp/ui/gestion/notification/points_notification_manager.dart';

class GestionViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final PointsNotificationManager _pointsNotificationManager =
      PointsNotificationManager(NotificationService());

  bool loadingPoints = false;
  int puntos = 0;

  DateTime? puntosVencimiento;

  bool loadingHistorial = false;
  List<DocumentSnapshot> historial = [];
  List<DocumentSnapshot> historialOriginal = [];

  final inputBuscar = TextEditingController();
  List<String> filtrosEstado = [];

  Future<void> cargarPuntos(BuildContext context) async {
    loadingPoints = true;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      loadingPoints = false;
      notifyListeners();
      return;
    }

    final docRef = _db.collection("users").doc(uid);
    final doc = await docRef.get();

    final data = doc.data() ?? {};

    puntos = (data["puntos"] ?? 0) as int;

    // leer vencimiento
    final ts = data["puntosVencimiento"] as Timestamp?;
    if (ts != null) {
      puntosVencimiento = ts.toDate();
    } else {
      if (puntos > 0) {
        final nuevaFecha = DateTime.now().add(const Duration(days: 30));
        puntosVencimiento = nuevaFecha;

        await docRef.update({
          "puntosVencimiento": Timestamp.fromDate(nuevaFecha),
        });
      }
    }

    loadingPoints = false;
    notifyListeners();

    // --------------------------
    // LÓGICA DE NOTIFICACIONES
    // --------------------------
    final notifSettings = context.read<NotificationSettingsProvider>();

    await _pointsNotificationManager.procesarNotificaciones(
      puntos: puntos,
      puntosVencimiento: puntosVencimiento,
      settings: notifSettings,
    );
  }

  Future<void> cargarHistorial() async {
    loadingHistorial = true;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      loadingHistorial = false;
      notifyListeners();
      return;
    }

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
    filtrosEstado = estados;

    if (estados.isEmpty) {
      historial = List.from(historialOriginal);
    } else {
      historial = historialOriginal.where((doc) {
        final estado = (doc.get("estado") ?? "").toString().toLowerCase();
        return estados.contains(estado);
      }).toList();
    }

    notifyListeners();
  }

  void limpiarFiltros() {
    filtrosEstado = [];
    historial = List.from(historialOriginal);
    notifyListeners();
  }
}
