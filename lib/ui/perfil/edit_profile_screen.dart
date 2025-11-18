import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reciclapp/data/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'No hay usuario logueado.';
      }

      bool emailChanged = false;
      String? newEmailForMsg;

      // ---------- NOMBRE ----------
      final newName = _nameCtrl.text.trim();
      if (newName.isNotEmpty && newName != (user.displayName ?? '')) {
        // podés usar tu AuthService si adentro hace esto mismo
        await user.updateDisplayName(newName);
      }

      // ---------- EMAIL ----------
      final newEmail = _emailCtrl.text.trim();
      if (newEmail.isNotEmpty && newEmail != (user.email ?? '')) {
        await user.verifyBeforeUpdateEmail(newEmail);
        emailChanged = true;
        newEmailForMsg = newEmail;
      }

      // ---------- CONTRASEÑA ----------
      if (_newPassCtrl.text.isNotEmpty) {
        if (_newPassCtrl.text != _confirmPassCtrl.text) {
          throw 'Las contraseñas no coinciden.';
        }
        await user.updatePassword(_newPassCtrl.text.trim());
      }

      // Esto fuerza a Firebase a recargar los datos del usuario
      await user.reload();

      if (!mounted) return;

      if (emailChanged && newEmailForMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Te enviamos un correo a $newEmailForMsg para confirmar el cambio de email.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente.')),
        );
      }

      Navigator.of(context).pop(); // Volver al perfil
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Nombre
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El correo no puede estar vacío.';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.lock_outline, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Cambiar contraseña (opcional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _newPassCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _confirmPassCtrl,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _saveChanges,
                  icon: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_loading ? 'Guardando...' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
