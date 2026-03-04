import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> loginUser(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot doc = await _firestore.collection('Users').doc(cred.user!.uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) { print(e); } return null;
  }

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'cancelled';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken
      );
      
      UserCredential cred = await _auth.signInWithCredential(credential);
      DocumentSnapshot doc = await _firestore.collection('Users').doc(cred.user!.uid).get();
      
      if (doc.exists) {
        return doc['role'] == 'admin' ? 'admin' : 'customer';
      } else {
        return 'new_user';
      }
    } catch (e) { return 'error: $e'; }
  }
}
