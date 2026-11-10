import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads and writes the `users/{uid}` Firestore documents.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(
    String uid, {
    String email = '',
    String phone = '',
    String displayName = '',
    int emailVerified = 0,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phone': phone,
      // 1 = email verified, 0 = not verified yet (unverified accounts are
      // deleted after AuthService.unverifiedAccountLifetime).
      'emailVerified': emailVerified,
      'favoriteTeams': [],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Sets `emailVerified` to 1, creating the profile document if missing.
  Future<void> markEmailVerified(
    String uid, {
    String email = '',
    String displayName = '',
  }) async {
    final doc = _firestore.collection('users').doc(uid);
    if ((await doc.get()).exists) {
      await doc.update({'emailVerified': 1});
    } else {
      await createUserDocument(
        uid,
        email: email,
        displayName: displayName,
        emailVerified: 1,
      );
    }
  }

  Future<void> deleteUserDocument(String uid) =>
      _firestore.collection('users').doc(uid).delete();

  Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data();
  }
}
