import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'view_model/recycle_detail_view_model.dart';

import 'widgets/evidence_image.dart';
import 'widgets/data_card.dart';
import 'widgets/note_card.dart';
import 'widgets/map_card.dart';

class RecycleDetailScreen extends StatelessWidget {
  final String docId;

  const RecycleDetailScreen({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecycleDetailViewModel()..load(docId),
      child: const _RecycleDetailBody(),
    );
  }
}

class _RecycleDetailBody extends StatelessWidget {
  const _RecycleDetailBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecycleDetailViewModel>();

    if (vm.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = vm.data;
    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("Registro no encontrado")),
      );
    }

    final materiales = (data["materiales"] as List?)?.join(", ") ?? "-";
    final tagsList =
        (data["tags"] as List?)?.map((e) => e.toString()).toList() ?? [];

    // ecopuntoNombre + direccionCompleta
    final ecopuntoNombre =
        (data["ecopuntoNombre"] ?? data["ecopunto"] ?? "-").toString();

    final direccionCompleta =
        (data["direccionCompleta"] ?? "").toString();

    final ecopuntoLabel = direccionCompleta.isNotEmpty
        ? "$ecopuntoNombre\n$direccionCompleta"
        : ecopuntoNombre;

    final estado = (data["estado"] ?? "-").toString().toUpperCase();
    final puntos = data["puntos"] ?? 0;
    final nota = data["nota"] ?? "-";
    final fechaTimestamp = data["confirmedAt"];

    // Coords ahora desde lat/lng en Firestore, NO parseando string
    final lat = (data["lat"] as num?)?.toDouble();
    final lng = (data["lng"] as num?)?.toDouble();

    LatLng coords;
    if (lat != null && lng != null) {
      coords = LatLng(lat, lng);
    } else {
      coords = const LatLng(0, 0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle Reciclaje"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => vm.confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EvidenceImageWidget(imageBytes: vm.evidenceBytes),
                  const SizedBox(height: 8),

                  DataCardWidget(
                    estado: estado,
                    puntos: puntos,
                    fechaTimestamp: fechaTimestamp,
                    tags: tagsList,
                    materiales: materiales,
                  ),

                  const SizedBox(height: 8),

                  NoteCardWidget(
                    nota: nota,
                    onEdit: () => vm.showEditNoteDialog(context),
                  ),

                  const SizedBox(height: 8),

                  // aca le mando coordenadas y con direccion completa
                  MapCardWidget(
                    coords: coords,
                    ecopunto: ecopuntoLabel,
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
