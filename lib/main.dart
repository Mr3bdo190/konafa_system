import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/admin/admin_home_wrapper.dart';
import 'screens/intro/onboarding_screen.dart';

bool showOnboard = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Error: $e");
  }
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  showOnboard = !(prefs.getBool('seenOnboard') ?? false);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام كنافة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, scaffoldBackgroundColor: const Color(0xFFF5F3F8), fontFamily: 'Cairo'),
      home: showOnboard ? const OnboardingScreen() : const MaintenanceGuard(),
    );
  }
}

// حارس وضع الصيانة (يمنع دخول العملاء لو التطبيق مقفول)
class MaintenanceGuard extends StatelessWidget {
  const MaintenanceGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Settings').doc('App').snapshots(),
      builder: (context, snapshot) {
        bool isMaintenance = false;
        if (snapshot.hasData && snapshot.data!.exists) {
          isMaintenance = snapshot.data!['isMaintenance'] ?? false;
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            
            if (authSnapshot.hasData && authSnapshot.data != null) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Users').doc(authSnapshot.data!.uid).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    String role = userSnapshot.data!['role'] ?? 'customer';
                    
                    // لو أدمن، يدخل دايماً حتى لو في صيانة
                    if (role == 'admin') return const AdminHomeWrapper();
                    
                    // لو عميل والتطبيق في صيانة، يظهرله شاشة الصيانة
                    if (isMaintenance) return const MaintenanceScreen();
                    
                    return const CustomerHomeScreen();
                  }
                  return const LoginScreen();
                },
              );
            }
            if (isMaintenance) return const MaintenanceScreen();
            return const LoginScreen();
          },
        );
      },
    );
  }
}

// شاشة الصيانة التي تظهر للعملاء
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings_suggest, size: 120, color: Colors.orange.shade300),
              const SizedBox(height: 30),
              const Text('عذراً، التطبيق في وضع الصيانة 🛠️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 15),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Text('نعمل حالياً على تطوير التطبيق لتقديم خدمة أفضل لكم. سنعود قريباً!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }
}
