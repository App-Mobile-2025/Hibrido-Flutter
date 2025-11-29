import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:reciclapp/data/services/profile_service.dart';
import 'package:reciclapp/ui/login/login_screen.dart';
import 'package:reciclapp/ui/perfil/edit_profile_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _uploadingPhoto = false;

  final ProfileService _profileService = ProfileService();

  Future<void> _showPhotoOptions(User user) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir de la galería'),
                onTap: () async {
                  Navigator.pop(context);
                  await _handlePickAndUpload(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar una foto'),
                onTap: () async {
                  Navigator.pop(context);
                  await _handlePickAndUpload(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePickAndUpload(ImageSource source) async {
    try {
      setState(() => _uploadingPhoto = true);

      final url = await _profileService.pickAndUploadProfilePhoto(source);

      if (!mounted) return;

      if (url != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la foto: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No hay usuario logueado')),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFE8F5E9),
          appBar: AppBar(
            title: const Text("Mi Perfil"),
            centerTitle: true,
          ),
          body: FutureBuilder<Map<String, dynamic>?>(
            future: _profileService.getUserProfile(),
            builder: (context, profileSnap) {
              if (profileSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = profileSnap.data ?? {};
              final String name = (data['name'] ?? '').toString();
              final String lastname = (data['lastname'] ?? '').toString();
              final String email =
                  (data['email'] ?? user.email ?? 'Correo no disponible')
                      .toString();

              final String fullName = (name.isEmpty && lastname.isEmpty)
                  ? (user.displayName ?? 'Usuario')
                  : '$name $lastname';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // BANNER ECO FULL WIDTH
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 230,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/fondo_eco.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: _uploadingPhoto
                                ? null
                                : () => _showPhotoOptions(user),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.green.shade200,
                                    backgroundImage: (user.photoURL != null)
                                        ? NetworkImage(user.photoURL!)
                                        : null,
                                    child: (user.photoURL == null)
                                        ? const Icon(
                                            Icons.person,
                                            size: 70,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: _uploadingPhoto
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.camera_alt,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // NOMBRE + EMAIL
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // CARD CON INFO DETALLADA (nombre y apellido separados)
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    Icons.email,
                                    "Correo",
                                    email,
                                  ),
                                  const Divider(),
                                  _buildInfoRow(
                                    Icons.person_outline,
                                    "Nombre",
                                    name.isEmpty ? 'No configurado' : name,
                                  ),
                                  const Divider(),
                                  _buildInfoRow(
                                    Icons.badge_outlined,
                                    "Apellido",
                                    lastname.isEmpty
                                        ? 'No configurado'
                                        : lastname,
                                  ),
                                  const Divider(),
                                  _buildInfoRow(
                                    Icons.verified_user,
                                    "Estado",
                                    "Activo",
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // BOTÓN EDITAR PERFIL
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text("Editar perfil"),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // BOTÓN CERRAR SESIÓN
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();

                                if (!context.mounted) return;

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (_) => false,
                                );
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text("Cerrar sesión"),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
