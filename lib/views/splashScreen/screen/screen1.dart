import 'package:flutter/material.dart';
class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/onboarding_icon_1.png')
      ],
    );
  }
}