import 'package:flutter/material.dart';

import 'package:reciclapp/data/services/profile_service.dart';
import 'package:reciclapp/ui/perfil/view_model/edit_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final EditProfileController _controller = EditProfileController();

  late TextEditingController _nameCtrl;
  late TextEditingController _lastnameCtrl;
  late TextEditingController _emailCtrl;
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _saving = false;
  bool _loadingProfile = true;

  EditProfileData? _profileData;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _lastnameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _controller.loadProfileData();

      if (!mounted) return;

      _profileData = data;

      if (data != null) {
        _nameCtrl.text = data.name;
        _lastnameCtrl.text = data.lastname;
        _emailCtrl.text = data.email;
      }
    } finally {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastnameCtrl.dispose();
    _emailCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final name = _nameCtrl.text.trim();
      final lastname = _lastnameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final newPass = _newPassCtrl.text.trim();
      final confirmPass = _confirmPassCtrl.text.trim();

      // Si alguno de los campos de pass está cargado, exigimos ambos
      String? passToSend;
      String? confirmToSend;
      if (newPass.isNotEmpty || confirmPass.isNotEmpty) {
        if (newPass != confirmPass) {
          throw Exception('Las contraseñas nuevas no coinciden.');
        }
        passToSend = newPass;
        confirmToSend = confirmPass;
      }

      final result = await _controller.updateProfile(
        name: name,
        lastname: lastname,
        email: email,
        newPassword: passToSend,
        confirmPassword: confirmToSend,
      );

      if (!mounted) return;

      var msg = 'Perfil actualizado correctamente.';
      if (result.emailChanged && result.newEmail != null) {
        msg += '\nRevisá ${result.newEmail} para confirmar el cambio de correo.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar perfil'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final data = _profileData;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + nombre completo
            if (data != null)
              Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: (data.photoUrl != null)
                        ? NetworkImage(data.photoUrl!)
                        : null,
                    child: (data.photoUrl == null)
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Nombre
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresá tu nombre'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // Apellido
                  TextFormField(
                    controller: _lastnameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(Icons.badge),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresá tu apellido'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresá tu correo';
                      }
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nueva contraseña
                  TextFormField(
                    controller: _newPassCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña (opcional)',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  // Confirmar nueva contraseña
                  TextFormField(
                    controller: _confirmPassCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Repetir nueva contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _saveProfile,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
