// lib/data/services/profile_service.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _db;

  ProfileService({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    ImagePicker? picker,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker(),
        _db = firestore ?? FirebaseFirestore.instance;

  // ==============================
  // OBTENER PERFIL DESDE FIRESTORE
  // ==============================
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snap = await _db.collection('users').doc(user.uid).get();
    if (!snap.exists) return null;

    return snap.data();
  }

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
  // PERFIL (NOMBRE / APELLIDO / EMAIL / PASS)
  // ==============================
  Future<ProfileUpdateResult> updateProfile({
    required String name,
    required String lastname,
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

    // ---------- NOMBRE + APELLIDO ----------
    final trimmedName = name.trim();
    final trimmedLastname = lastname.trim();
    final fullName = [trimmedName, trimmedLastname]
        .where((p) => p.isNotEmpty)
        .join(' ')
        .trim();

    if (fullName.isNotEmpty && fullName != (user.displayName ?? '')) {
      await user.updateDisplayName(fullName);
    }

    // ---------- EMAIL (AUTH) ----------
    final newEmail = email.trim();
    if (newEmail.isNotEmpty && newEmail != (user.email ?? '')) {
      // envía mail de verificación al NUEVO correo
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

    // ---------- FIRESTORE: /users/{uid} ----------
    final uid = user.uid;
    final userDocRef = _db.collection('users').doc(uid);

    final Map<String, dynamic> dataToUpdate = {
      'name': trimmedName,
      'lastname': trimmedLastname,
    };

    if (newEmail.isNotEmpty) {
      dataToUpdate['email'] = newEmail;
    }

    // si el doc existe lo actualizamos; si no, lo creamos
    final docSnap = await userDocRef.get();
    if (docSnap.exists) {
      await userDocRef.update(dataToUpdate);
    } else {
      await userDocRef.set({
        'uid': uid,
        ...dataToUpdate,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await user.reload();

    return ProfileUpdateResult(
      emailChanged: emailChanged,
      newEmail: newEmailForMsg,
    );
  }
}
