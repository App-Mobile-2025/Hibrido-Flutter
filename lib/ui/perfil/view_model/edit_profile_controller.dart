import 'package:firebase_auth/firebase_auth.dart';
import 'package:reciclapp/data/services/profile_service.dart';

/// DTO con los datos iniciales del perfil
class EditProfileData {
  final String name;
  final String lastname;
  final String email;
  final String? photoUrl;
  final String fullName;

  EditProfileData({
    required this.name,
    required this.lastname,
    required this.email,
    required this.photoUrl,
    required this.fullName,
  });
}

class EditProfileController {
  final ProfileService _profileService;
  final FirebaseAuth _auth;

  EditProfileController({
    ProfileService? profileService,
    FirebaseAuth? auth,
  })  : _profileService = profileService ?? ProfileService(),
        _auth = auth ?? FirebaseAuth.instance;

  /// Carga datos desde Firestore y, si no existe el doc, usa FirebaseAuth
  Future<EditProfileData?> loadProfileData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final data = await _profileService.getUserProfile();

    String name;
    String lastname;
    String email;

    if (data != null) {
      name = (data['name'] ?? '').toString();
      lastname = (data['lastname'] ?? '').toString();
      email = (data['email'] ?? user.email ?? '').toString();
    } else {
      // Fallback si no hay doc en Firestore
      final displayName = user.displayName ?? '';
      if (displayName.contains(' ')) {
        final parts = displayName.split(' ');
        name = parts.first;
        lastname = parts.sublist(1).join(' ');
      } else {
        name = displayName;
        lastname = '';
      }
      email = user.email ?? '';
    }

    final composedFullName = ('$name $lastname').trim();
    final fullName =
        composedFullName.isEmpty ? (user.displayName ?? 'Usuario') : composedFullName;

    return EditProfileData(
      name: name,
      lastname: lastname,
      email: email,
      photoUrl: user.photoURL,
      fullName: fullName,
    );
  }

  /// Actualiza el perfil delegando en ProfileService
  Future<ProfileUpdateResult> updateProfile({
    required String name,
    required String lastname,
    required String email,
    String? newPassword,
    String? confirmPassword,
  }) {
    return _profileService.updateProfile(
      name: name,
      lastname: lastname,
      email: email,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
