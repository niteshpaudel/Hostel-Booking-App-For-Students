import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore database = FirebaseFirestore.instance;
Future<void> addUserDetails(
    {required String username,
    required String phone,
    required User? user}) async {
  if (user != null) {
    await database.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': username,
      'phone': phone,
    });
  }
}
