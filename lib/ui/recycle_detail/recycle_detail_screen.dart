import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'widgets/evidence_image.dart';
import 'widgets/data_card.dart';
import 'widgets/note_card.dart';
import 'widgets/map_card.dart';
import 'widgets/action_buttons.dart';

class RecycleDetailScreen extends StatefulWidget {
  final String docId;

  const RecycleDetailScreen({super.key, required this.docId});

  @override
  State<RecycleDetailScreen> createState() => _RecycleDetailScreenState();
}

class _RecycleDetailScreenState extends State<RecycleDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  Uint8List? evidenceBytes;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("reciclajes")
          .doc(widget.docId)
          .get();

      if (!doc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registro no encontrado")),
          );
        }
        Navigator.pop(context);
        return;
      }

      data = doc.data();

      await loadEvidenceImage();
      setState(() => loading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error cargando: $e")),
        );
      }
      Navigator.pop(context);
    }
  }

  Future<void> loadEvidenceImage() async {
    try {
      final evidenciaRefId = data?["evidenciaRefId"];
      if (evidenciaRefId == null) return;

      final evDoc = await FirebaseFirestore.instance
          .collection("evidencias")
          .doc(evidenciaRefId)
          .get();

      final url = evDoc["url"];
      final ref = FirebaseStorage.instance.refFromURL(url);
      evidenceBytes = await ref.getData(5 * 1024 * 1024);
    } catch (_) {}
  }

  LatLng parseCoords(String coords) {
    final regex = RegExp(r'\((-?\d+,\d+),\s*(-?\d+,\d+)\)');
    final match = regex.firstMatch(coords);

    if (match != null) {
      final lat = double.parse(match.group(1)!.replaceAll(",", "."));
      final lng = double.parse(match.group(2)!.replaceAll(",", "."));
      return LatLng(lat, lng);
    }

    return const LatLng(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final materiales = (data?["materiales"] as List?)?.join(", ") ?? "-";
    final tagsList = (data?["tags"] as List?)?.map((e) => e.toString()).toList() ?? [];
    final ecopunto = data?["ecopunto"] ?? "-";
    final estado = (data?["estado"] ?? "-").toString().toUpperCase();
    final puntos = data?["puntos"] ?? 0;
    final nota = data?["nota"] ?? "-";
    final fechaTimestamp = data?["confirmedAt"] as Timestamp?;

    final coords = parseCoords(ecopunto);

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle Reciclaje")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EvidenceImageWidget(imageBytes: evidenceBytes),
                  const SizedBox(height: 8),
                  DataCardWidget(
                    estado: estado,
                    puntos: puntos,
                    fechaTimestamp: fechaTimestamp,
                    tags: tagsList,
                    materiales: materiales,
                  ),
                  const SizedBox(height: 8),
                  NoteCardWidget(nota: nota),
                  const SizedBox(height: 8),
                  MapCardWidget(coords: coords, ecopunto: ecopunto),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ActionButtonsWidget(),
          ),
        ],
      ),
    );
  }
}
