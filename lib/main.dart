import 'package:fillahub/api/firebase_api.dart';
import 'package:fillahub/components/splash_screen.dart';
import 'package:fillahub/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: SplashScreen(),
      routes: {
        'home_screen': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == 'home_screen') {
          final args = settings.arguments as Map<String, dynamic>?;
          final postId = args?['postId'] as String?;
          return MaterialPageRoute(
            builder: (context) {
              return HomePage(postId: postId);
            },
          );
        }
        return null;
      },
    );
  }
}
