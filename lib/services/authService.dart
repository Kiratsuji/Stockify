import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future userSignUp(String email, String password, String username) async{
    try{
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await resultado.user?.updateDisplayName(username);
      await resultado.user?.reload();

      return _auth.currentUser;
    } on FirebaseAuthException catch (e){
      throw Exception(e.message);
    }
  }

  Future login(String email, String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch(e){
      throw Exception(e);
    }
  }

  Future logout() async{
    await _auth.signOut();
  }
}