import 'package:fillahub/auth/auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToAuthPage();
  }

  _navigateToAuthPage() async {
    await Future.delayed(Duration(seconds: 3), () {}); // Duration of the splash screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/fillahub1.png'),
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Text('Welcome to Fillahub', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
