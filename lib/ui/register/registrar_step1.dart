import 'package:flutter/material.dart';
import 'package:reciclapp/ui/register/mapa/ecopuntos_ba.dart';
import 'package:reciclapp/ui/register/mapa/ecopuntos_map.screan.dart';
import 'package:reciclapp/ui/register/registrar_step2.dart';

class RegistrarStep1Screen extends StatefulWidget {
  const RegistrarStep1Screen({super.key});

  @override
  State<RegistrarStep1Screen> createState() => _RegistrarStep1ScreenState();
}

class _RegistrarStep1ScreenState extends State<RegistrarStep1Screen> {
  final _ecopuntoController = TextEditingController();

    Ecopunto? _ecopuntoSeleccionado;

  
  final Map<String, bool> _materiales = {
    'Cartón': false,
    'Plástico': false,
    'Papel': false,
    'Metal': false,
    'Vidrio': false,
    'Aceite': false,
  };

  final Map<String, IconData> _materialesIconos = {
    'Cartón': Icons.inventory_2,
    'Plástico': Icons.local_drink,
    'Papel': Icons.description,
    'Metal': Icons.hardware,
    'Vidrio': Icons.wine_bar,
    'Aceite': Icons.water_drop,
  };

Future<void> _abrirMapaEcopunto() async {
  final resultado = await Navigator.push<Ecopunto>(
    context,
    MaterialPageRoute(
      builder: (_) => const EcopuntoMapScreen(),
    ),
  );

  if (resultado != null) {
    setState(() {
      _ecopuntoSeleccionado = resultado;
      _ecopuntoController.text =
          '${resultado.nombre} (${resultado.lat.toStringAsFixed(5)}, '
          '${resultado.lng.toStringAsFixed(5)})';
    });
  }
}



  @override
  void dispose() {
    _ecopuntoController.dispose();
    super.dispose();
  }

  void _siguiente() {
    final ecopunto = _ecopuntoController.text.trim();
    final materialesSeleccionados = _materiales.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (ecopunto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el lugar de entrega')),
      );
      return;
    }

    if (materialesSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un material')),
      );
      return;
    }

    // ir al paso 2
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarStep2Screen(
          ecopunto: ecopunto,
          materiales: materialesSeleccionados,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Registrar Reciclaje (1/2)'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de progreso
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Lugar de entrega
            const Text(
              'Lugar de entrega',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa el nombre del ecopunto donde entregarás',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            TextField(
  controller: _ecopuntoController,
  readOnly: true,
  onTap: _abrirMapaEcopunto, // abre el mapa
  decoration: InputDecoration(
    hintText: 'Tocá para elegir un Ecopunto en el mapa',
    prefixIcon: const Icon(Icons.location_on, color: Colors.green),
    suffixIcon: const Icon(Icons.map, color: Colors.green),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.green.shade100),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
  ),
),


            const SizedBox(height: 32),

            const Text(
              'Tipo de material reciclado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona todos los materiales que vas a reciclar',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // Grid de materiales
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _materiales.length,
              itemBuilder: (context, index) {
                final material = _materiales.keys.elementAt(index);
                final seleccionado = _materiales[material]!;
                final icono = _materialesIconos[material]!;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _materiales[material] = !seleccionado;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: seleccionado ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: seleccionado
                            ? Colors.green
                            : Colors.green.shade100,
                        width: 2,
                      ),
                      boxShadow: seleccionado
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icono,
                          size: 36,
                          color: seleccionado ? Colors.white : Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          material,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: seleccionado ? Colors.white : Colors.green,
                          ),
                        ),
                        if (seleccionado)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Botón siguiente
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _siguiente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SIGUIENTE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
