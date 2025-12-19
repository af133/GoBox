import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          Center(child: Image.asset('assets/onboarding_icon_1.png')),
          Center(child: Image.asset('assets/onboarding_icon_2.png')),
          Center(child: Image.asset('assets/onboarding_screen_3.png')),
        ],
      ),
    );
  }
}
