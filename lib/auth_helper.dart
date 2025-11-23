import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  // Add your authentication helper methods here
  final firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  final clientId =
      '366699841816-7pnej4ahlrbopp4vh3g8s98tnp44n2r9.apps.googleusercontent.com';
  final serverClientId =
      '366699841816-of58uiok69o80e0so9k4barndv0i13oa.apps.googleusercontent.com';

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    unawaited(
      googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      ),
    );

    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await firebaseAuth.signInWithCredential(credential);
  }

  Stream<User?> checkUserSignInState() {
    final state = firebaseAuth.authStateChanges();
    return state;
  }

  signOutWithGoogle() {
    googleSignIn.signOut();
    firebaseAuth.signOut();
  }
}