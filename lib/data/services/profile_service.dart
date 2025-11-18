// lib/data/services/profile_service.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUpdateResult {
  final bool emailChanged;
  final String? newEmail;

  ProfileUpdateResult({
    required this.emailChanged,
    this.newEmail,
  });
}

class ProfileService {
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  ProfileService({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  // ==============================
  // FOTO DE PERFIL
  // ==============================
  Future<String?> pickAndUploadProfilePhoto(ImageSource source) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario logueado');
    }

    final XFile? pickedFile =
        await _picker.pickImage(source: source, maxWidth: 600);

    if (pickedFile == null) return null; // canceló

    final file = File(pickedFile.path);

    final storageRef = _storage
        .ref()
        .child('users')
        .child(user.uid)
        .child('avatar.jpg');

    await storageRef.putFile(file);

    final url = await storageRef.getDownloadURL();

    await user.updatePhotoURL(url);
    await user.reload();

    return url;
  }

  // ==============================
  // PERFIL (NOMBRE / EMAIL / PASS)
  // ==============================
  Future<ProfileUpdateResult> updateProfile({
    required String name,
    required String email,
    String? newPassword,
    String? confirmPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario logueado.');
    }

    bool emailChanged = false;
    String? newEmailForMsg;

    // ---------- NOMBRE ----------
    final newName = name.trim();
    if (newName.isNotEmpty && newName != (user.displayName ?? '')) {
      await user.updateDisplayName(newName);
    }

    // ---------- EMAIL ----------
    final newEmail = email.trim();
    if (newEmail.isNotEmpty && newEmail != (user.email ?? '')) {
      await user.verifyBeforeUpdateEmail(newEmail);
      emailChanged = true;
      newEmailForMsg = newEmail;
    }

    // ---------- CONTRASEÑA ----------
    if (newPassword != null && newPassword.isNotEmpty) {
      if (newPassword != confirmPassword) {
        throw Exception('Las contraseñas no coinciden.');
      }
      await user.updatePassword(newPassword.trim());
    }

    await user.reload();

    return ProfileUpdateResult(
      emailChanged: emailChanged,
      newEmail: newEmailForMsg,
    );
  }
}
