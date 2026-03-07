import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'أشهى كنافة في مصر 😋',
      'desc': 'بنقدملك تشكيلة رائعة من الحلويات الشرقية المصنوعة بحب وعناية عشان تظبط مزاجك.',
      'icon': 'cake'
    },
    {
      'title': 'تتبع طلبك لحظة بلحظة 🛵',
      'desc': 'اطلب اللي نفسك فيه وتابع حالة الأوردر بتاعك من المطبخ لحد باب بيتك.',
      'icon': 'delivery_dining'
    },
    {
      'title': 'عروض وخصومات مستمرة 🎁',
      'desc': 'خليك دايماً معانا واستمتع بأقوى الخصومات والكوبونات الحصرية لعملائنا المميزين.',
      'icon': 'local_offer'
    }
  ];

  void _finishOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboard', true);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  IconData _getIcon(String name) {
    if (name == 'cake') return Icons.cake;
    if (name == 'delivery_dining') return Icons.delivery_dining;
    return Icons.local_offer;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                        child: Icon(_getIcon(_slides[index]['icon']!), size: 120, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 50),
                      Text(_slides[index]['title']!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      Text(_slides[index]['desc']!, style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5), textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 40, left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(_slides.length, (index) => buildDot(index, context)),
                  ),
                  _currentIndex == _slides.length - 1
                      ? ElevatedButton(
                          onPressed: _finishOnboarding,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                          child: const Text('ابدأ الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        )
                      : FloatingActionButton(
                          onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn),
                          backgroundColor: Colors.deepPurple,
                          child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10, width: _currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: _currentIndex == index ? Colors.deepPurple : Colors.grey.shade300),
    );
  }
}
