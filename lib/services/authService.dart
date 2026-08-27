import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Cadastro de usuário com criação do documento inicial no Firestore
  Future<User?> userSignUp(String email, String password, String username) async {
    try {
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = resultado.user;

      if (user != null) {
        await user.updateDisplayName(username);
        await user.reload();

        // 1. Cria o documento do usuário em /users/{uid}
        // O companyId será preenchido posteriormente durante o Onboarding (Passo 3)
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username,
          'email': email,
          'companyId': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Login padrão
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Recupera as informações do usuário salvas no Firestore (ex: companyId)
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // Desconecta o usuário
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Reautenticação antes de alterações sensíveis
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

  // Atualiza nome de exibição no Firebase Auth e no Firestore
  Future<void> updateUsername(String username) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(username);
      await user.reload();

      await _db.collection('users').doc(user.uid).update({
        'username': username,
      });
    }
  }

  // Solicita verificação/alteração de e-mail
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