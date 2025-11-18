import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_model/gestion_view_model.dart';
import 'widgets/reciclaje_item.dart';
import 'widgets/filtro_bottomsheet.dart';

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
          // --- Bloque Puntos ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (vm.loadingPoints)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Text(
                        vm.puntos.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 4),
                    const Text(
                      "Puntos disponibles",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/canje");
                      },
                      child: const Text("Ir a canje"),
                    )
                  ],
                ),
              ),
            ),
          ),

          // --- Búsqueda y filtro ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: vm.inputBuscar,
                    decoration: InputDecoration(
                      hintText: "Buscar nota...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: vm.buscarNota,
                  child: const Text("Buscar"),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => FiltroBottomsheet(
                        seleccionInicial: const [],
                        onAplicar: vm.aplicarFiltro,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --- Historial ---
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
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/detalle_reciclaje",
                            arguments: doc,
                          );
                        },
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
