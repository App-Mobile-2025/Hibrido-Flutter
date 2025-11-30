import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CanjeScreen extends StatelessWidget {
  const CanjeScreen({super.key});

  // Traer puntos desde Firestore (users/{uid}.puntos)
  Future<int> _getUserPoints() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    final data = doc.data();
    return (data?["puntos"] ?? 0) as int;
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"icon": Icons.storefront, "label": "Gastronomía"},
      {"icon": Icons.spa, "label": "Vivero"},
      {"icon": Icons.local_shipping, "label": "Envíos"},
      {"icon": Icons.book, "label": "Libros"},
      {"icon": Icons.home, "label": "Hogar"},
      {"icon": Icons.fitness_center, "label": "Experiencias"},
    ];

    final rewards = [
      {
        "title": "10% OFF en EcoVivero",
        "desc": "Mostrando tu QR de ReciclApp",
        "points": 250
      },
      {
        "title": "Café gratis eco-friendly",
        "desc": "Válido en locales adheridos",
        "points": 180
      },
      {
        "title": "Envío sustentable bonificado",
        "desc": "Pedidos reciclables",
        "points": 300
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Canjea tus puntos"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Tus puntos (con FutureBuilder) ----
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<int>(
              future: _getUserPoints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Card(
                    elevation: 2,
                    color: Colors.green.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                final puntos = snapshot.data ?? 0;

                return Card(
                  elevation: 2,
                  color: Colors.green.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.stars,
                            size: 40, color: Colors.green.shade900),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tus puntos disponibles",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "$puntos pts",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ---- Categorías ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Categorías",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, i) {
                final c = categories[i];
                return Column(
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 4,
                            offset: Offset(1, 3),
                            color: Colors.black12,
                          )
                        ],
                      ),
                      child: Icon(
                        c["icon"] as IconData,
                        size: 36,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(c["label"] as String),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemCount: categories.length,
            ),
          ),

          const SizedBox(height: 16),

          // ---- Beneficios disponibles ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Beneficios disponibles",
              style: TextStyle(
                fontSize: 18,
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rewards.length,
              itemBuilder: (_, i) {
                final r = rewards[i];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.card_giftcard,
                            size: 34,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r["title"].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r["desc"].toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${r["points"]} pts",
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            // acá más adelante podés implementar el canje
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                          child: const Text("Canjear"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
