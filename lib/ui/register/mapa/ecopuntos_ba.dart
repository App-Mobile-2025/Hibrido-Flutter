class Ecopunto {
  final String nombre;
  final double lat;
  final double lng;

  const Ecopunto(this.nombre, this.lat, this.lng);
}

class EcopuntosBA {
  static const lista = <Ecopunto>[
    // ---- CABA ----
    Ecopunto("Ecopunto Palermo", -34.5715, -58.4216),
    Ecopunto("Ecopunto Caballito", -34.6187, -58.4429),
    Ecopunto("Ecopunto Recoleta", -34.5889, -58.3974),
    Ecopunto("Ecopunto Belgrano", -34.5626, -58.4561),
    Ecopunto("Ecopunto San Telmo", -34.6217, -58.3713),
    Ecopunto("Ecopunto La Boca", -34.6355, -58.3620),
    Ecopunto("Ecopunto Microcentro", -34.6037, -58.3816),
    Ecopunto("Ecopunto Almagro", -34.6093, -58.4202),
    Ecopunto("Ecopunto Villa Urquiza", -34.5737, -58.4904),
    Ecopunto("Ecopunto Flores", -34.6336, -58.4645),

    // ---- Zona Sur GBA ----
    Ecopunto("Ecopunto Quilmes Centro", -34.7245, -58.2534),
    Ecopunto("Ecopunto Ezpeleta", -34.7498, -58.2361),
    Ecopunto("Ecopunto Bernal", -34.7124, -58.2808),
    Ecopunto("Ecopunto Berazategui Centro", -34.7650, -58.2120),
    Ecopunto("Ecopunto Hudson", -34.7975, -58.1752),
    Ecopunto("Ecopunto Plátanos", -34.7890, -58.1703),
    Ecopunto("Ecopunto Florencio Varela Centro", -34.7964, -58.2733),
    Ecopunto("Ecopunto Bosques", -34.8167, -58.2692),
    Ecopunto("Ecopunto Zeballos", -34.8051, -58.2456),
    Ecopunto("Ecopunto San Eduardo", -34.7820, -58.3010),
  ];
}
