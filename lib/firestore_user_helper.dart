import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_note/models/user_model.dart';

class FirestoreUserHelper {
  final _userRef = FirebaseFirestore.instance
      .collection('users_notes')
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
        toFirestore: (userModel, _) => userModel.toJson(),
      );

  // Add user only if they don't exist (for signup)
  Future<void> addUser(UserModel user) async {
    try {
      // Check if user already exists
      final docSnapshot = await _userRef.doc(user.userId).get();

      if (!docSnapshot.exists) {
        // User doesn't exist, create new user document
        await _userRef.doc(user.userId).set(user);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check if user exists in Firestore
  Future<bool> userExists(String userId) async {
    try {
      final docSnapshot = await _userRef.doc(userId).get();
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  // Get user data
  Future<UserModel?> getUser(String userId) async {
    try {
      final docSnapshot = await _userRef.doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
