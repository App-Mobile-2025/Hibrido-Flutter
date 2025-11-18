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

  @override
  void initState() {
    super.initState();
    seleccion = List.from(widget.seleccionInicial);
  }

  @override
  Widget build(BuildContext context) {
    final opciones = ["Pendiente", "Aprobado", "Rechazado"];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...opciones.map((e) => CheckboxListTile(
                title: Text(e),
                value: seleccion.contains(e),
                onChanged: (v) {
                  setState(() {
                    v!
                        ? seleccion.add(e)
                        : seleccion.remove(e);
                  });
                },
              )),
          ElevatedButton(
            onPressed: () {
              widget.onAplicar(seleccion);
              Navigator.pop(context);
            },
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );
  }
}
