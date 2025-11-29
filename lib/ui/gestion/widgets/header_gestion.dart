import 'package:flutter/material.dart';

class HeaderGestion extends StatelessWidget {
  final int puntos;
  final bool loading;
  final int total;
  final int aprobados;
  final int pendientes;
  final int rechazados;
  final VoidCallback onCanje;

  const HeaderGestion({
    super.key,
    required this.puntos,
    required this.loading,
    required this.total,
    required this.aprobados,
    required this.pendientes,
    required this.rechazados,
    required this.onCanje,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Fila 1: puntos + botón
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Puntos
                  loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "$puntos",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 4),
                  // Label más pequeño debajo de los puntos
                  const Text(
                    "Puntos disponibles",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón "Ir a canje"
                  ElevatedButton(
                    onPressed: onCanje,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                     child: const Text(
                        "Ir a canje",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Fila 2: Total 
              Text(
                "Reciclajes totales: $total",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),


              // Fila 3: Aprobados, Pendientes, Rechazados
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _contador("Aprobados", aprobados, Colors.green.shade200),
                  _contador("Pendientes", pendientes, Colors.orange.shade200),
                  _contador("Rechazados", rechazados, const Color.fromARGB(255, 255, 128, 128)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _contador(String label, int valor, Color color) {
    return Column(
      children: [
        Text(
          "$valor",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
