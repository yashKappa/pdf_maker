import 'package:flutter/material.dart';
import 'main.dart'; // Import your main screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 6000), () { // 4.1 seconds delay
      if (mounted) { // Ensure the widget is still in the tree
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()), // Navigate to main screen
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          "assets/loading.gif", // Ensure it's in the correct path
          fit: BoxFit.cover, // Covers the entire screen
        ),
      ),
    );
  }
}
