import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  final FirebaseAuth _auth;

  AuthManager(this._auth);

  Future<FirebaseUser> signUp(String email, String password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<FirebaseUser> signIn(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<bool> reAuth(String password) async {
    FirebaseUser user = await _auth.currentUser();
    final AuthCredential credential = EmailAuthProvider
        .getCredential(email: user.email, password: password);
    AuthResult result = await user?.reauthenticateWithCredential(credential);
    return result?.user != null;
  }

  Future<void> updateEmail(String email) async {
    FirebaseUser user = await _auth.currentUser();
    await user?.updateEmail(email);
  }

  Future<void> updatePassword(String password) async {
    FirebaseUser user = await _auth.currentUser();
    await user?.updatePassword(password);
  }

  Future<dynamic> signOut() async {
    return _auth.signOut();
  }

  Future<bool> isSignedIn() async {
    FirebaseUser user = await _auth.currentUser();
    return user == null ? false : true;
  }

  Stream<FirebaseUser> onAuthStateChanged() {
    return _auth.onAuthStateChanged;
  }

  Future<dynamic> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}