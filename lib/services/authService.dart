import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future userSignUp(String email, String password, String username) async {
    try {
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await resultado.user?.updateDisplayName(username);
      await resultado.user?.reload();

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future logout() async {
    await _auth.signOut();
  }

  // Método para reautenticar o usuário antes de alterações sensíveis
  Future<void> reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
    } else {
      throw Exception('Usuário não encontrado');
    }
  }

  // Atualiza nome de exibição
  Future<void> updateUsername(String username) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(username);
      await user.reload();
    }
  }

  // Envia e-mail de verificação para alteração de e-mail
  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
    }
  }

  // Atualiza a senha
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }
}