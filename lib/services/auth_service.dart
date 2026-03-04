import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل حساب جديد
  Future<UserModel?> registerUser(String email, String password, String name, String phone) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        name: name,
        phone: phone,
        role: 'customer', // أي مستخدم جديد بيكون عميل افتراضياً
      );

      await _firestore.collection('Users').doc(cred.user!.uid).set(newUser.toMap());
      return newUser;
    } catch (e) {
      print("Error in register: $e");
      return null;
    }
  }

  // تسجيل الدخول
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot doc = await _firestore.collection('Users').doc(cred.user!.uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error in login: $e");
    }
    return null;
  }
}
