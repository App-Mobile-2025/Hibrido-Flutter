import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // registro
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // login
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // stream de cambios de sesión
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // usuario actual
  User? get currentUser => _auth.currentUser;

  // --------------------------------------------------------
  // EDITAR PERFIL (NOMBRE / EMAIL / CONTRASEÑA)
  // --------------------------------------------------------

  // Cambiar el nombre visible del usuario
  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // Cambiar email → envía un mail de verificación al nuevo correo
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw 'No hay usuario logueado.';
      }

      await user.verifyBeforeUpdateEmail(newEmail);

      // el email se termina de actualizar cuando el usuario
      // hace clic en el enlace que le llega al NUEVO correo.
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // Cambiar contraseña
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  // --------------------------------------------------------

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-not-found':
        return 'No existe un usuario con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      default:
        return e.message ?? 'Ocurrió un error de autenticación.';
    }
  }
}
