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
    final ecopunto = data["ecopunto"] ?? "-";
    final estado = (data["estado"] ?? "-").toString().toUpperCase();
    final puntos = data["puntos"] ?? 0;
    final nota = data["nota"] ?? "-";
    final fechaTimestamp = data["confirmedAt"];

    final coords = parseCoords(ecopunto);

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

                  MapCardWidget(coords: coords, ecopunto: ecopunto),
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
