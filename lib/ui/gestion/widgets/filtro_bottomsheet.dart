import 'package:flutter/material.dart';

class FiltroBottomsheet extends StatefulWidget {
  final List<String> seleccionInicial;
  final Function(List<String>) onAplicar;

  const FiltroBottomsheet({
    required this.seleccionInicial,
    required this.onAplicar,
    super.key,
  });

  @override
  State<FiltroBottomsheet> createState() => _FiltroBottomsheetState();
}

class _FiltroBottomsheetState extends State<FiltroBottomsheet> {
  List<String> seleccion = [];

  final opciones = ["pendiente", "aprobado", "rechazado"];

  final Map<String, Color> colorEstado = {
    "pendiente": Colors.orange.shade600,
    "aprobado": Colors.green.shade600,
    "rechazado": Colors.red.shade600,
  };

  @override
  void initState() {
    super.initState();
    seleccion = List.from(widget.seleccionInicial);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filtrar por estado",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // CHIPS PERSONALIZADOS 
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: opciones.map((estado) {
              estado = estado.toLowerCase();
              final activo = seleccion.contains(estado);
              return ChoiceChip(
                label: Text(
                  estado,
                  style: TextStyle(
                    color: activo ? Colors.white : colorEstado[estado],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: activo,
                selectedColor: colorEstado[estado],
                backgroundColor: colorEstado[estado]!.withOpacity(0.2),
                onSelected: (_) {
                  setState(() {
                    activo ? seleccion.remove(estado) : seleccion.add(estado);
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // BOTÓN LIMPIAR
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  seleccion.clear();
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Limpiar filtros",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // BOTÓN APLICAR FILTRO
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onAplicar(seleccion);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Aplicar filtros",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
