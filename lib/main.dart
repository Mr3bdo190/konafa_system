import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  // 1. السطر السحري لمنع الشاشة السوداء (يجب أن يكون أول شيء)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. الاتصال بفايربيز بشكل آمن
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("خطأ في تشغيل فايربيز: $e");
  }

  // 3. تشغيل واجهة التطبيق
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام كنافة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F3F8),
        fontFamily: 'Cairo', // لو بتستخدم خط معين، أو سيبه الافتراضي
      ),
      // توجيه المستخدم لشاشة تسجيل الدخول كبداية
      home: const LoginScreen(),
    );
  }
}
