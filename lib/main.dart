import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const KonafaApp(),
    ),
  );
}

class KonafaApp extends StatelessWidget {
  const KonafaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Konafa System',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Cairo', // لو حابب تضيف خط عربي بعدين
      ),
      home: const LoginScreen(),
    );
  }
}
