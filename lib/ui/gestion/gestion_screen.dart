import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_model/gestion_view_model.dart';
import '../recycle_detail/recycle_detail_screen.dart'; // Asegurate que la ruta sea correcta
import 'widgets/reciclaje_item.dart';
import 'widgets/filtro_bottomsheet.dart';
import 'widgets/header_gestion.dart';

class GestionScreen extends StatelessWidget {
  const GestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GestionViewModel()
        ..cargarPuntos()
        ..cargarHistorial(),
      child: const _GestionBody(),
    );
  }
}

class _GestionBody extends StatelessWidget {
  const _GestionBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GestionViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text("Gestión de Reciclajes"),
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),

          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HeaderGestion(
              puntos: vm.puntos,
              loading: vm.loadingPoints,
              total: vm.historialOriginal.length,
              aprobados: vm.historialOriginal
                  .where((e) => (e.get("estado") ?? "") == "Aprobado")
                  .length,
              pendientes: vm.historialOriginal
                  .where((e) => (e.get("estado") ?? "") == "Pendiente")
                  .length,
              rechazados: vm.historialOriginal
                  .where((e) => (e.get("estado") ?? "") == "Rechazado")
                  .length,
              onCanje: () {
                Navigator.pushNamed(context, "/canje");
              },
            ),
          ),

          const SizedBox(height: 8),

          // BUSCADOR Y FILTRO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BuscadorGestion(
              controller: vm.inputBuscar,
              onBuscar: vm.buscarNota,
              onFiltro: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (_) => FiltroBottomsheet(
                    seleccionInicial: vm.filtrosEstado,
                    onAplicar: vm.aplicarFiltro,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // LISTA
          Expanded(
            child: vm.loadingHistorial
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.historial.length,
                    itemBuilder: (_, i) {
                      final doc = vm.historial[i];

                      return ReciclajeItem(
                        doc: doc,
                        onTap: () async {
                          final deleted = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecycleDetailScreen(
                                docId: doc.id,
                              ),
                            ),
                          );

                          if (deleted == true) {
                            vm.cargarHistorial(); // 🔥 refresca automáticamente
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// BUSCADOR + FILTRO
class BuscadorGestion extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBuscar;
  final VoidCallback onFiltro;

  const BuscadorGestion({
    super.key,
    required this.controller,
    required this.onBuscar,
    required this.onFiltro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Buscar nota...",
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: onBuscar,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onFiltro,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.filter_alt, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
