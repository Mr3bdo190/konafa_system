import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. تسجيل الدخول العادي
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot doc = await _firestore.collection('Users').doc(cred.user!.uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) { print(e); } 
    return null;
  }

  // 2. إنشاء حساب جديد (هذه هي الدالة التي كانت مفقودة!)
  Future<UserModel?> registerUser(String email, String password, String name, String phone, String address) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      UserModel newUser = UserModel(
        uid: cred.user!.uid, 
        name: name, 
        email: email,
        phone: phone, 
        address: address, 
        role: 'customer'
      );
      await _firestore.collection('Users').doc(cred.user!.uid).set(newUser.toMap());
      return newUser;
    } catch (e) { print(e); } 
    return null;
  }

  // 3. تسجيل الدخول بحساب جوجل
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'cancelled';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, 
        idToken: googleAuth.idToken
      );
      
      UserCredential cred = await _auth.signInWithCredential(credential);
      DocumentSnapshot doc = await _firestore.collection('Users').doc(cred.user!.uid).get();
      
      if (doc.exists) {
        return doc['role'] == 'admin' ? 'admin' : 'customer';
      } else {
        return 'new_user';
      }
    } catch (e) {
      return 'error: $e';
    }
  }
}
