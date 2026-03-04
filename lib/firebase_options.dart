import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // حالياً هنستخدم إعدادات الويب اللي بعتها لتشغيل الموقع والتطبيق
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDWPN3hCNjW2arTtdrs3ueIZveHg9ie5gU',
    appId: '1:44212119840:web:8106de80c8c5abb6674f45',
    messagingSenderId: '44212119840',
    projectId: 'konafasystem',
    authDomain: 'konafasystem.firebaseapp.com',
    storageBucket: 'konafasystem.firebasestorage.app',
    measurementId: 'G-KJ406EDM0R',
  );
}

