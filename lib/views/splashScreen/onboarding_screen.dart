import 'package:flutter/material.dart';
import 'package:gobox/views/splashScreen/screen/screen1.dart';
import 'package:gobox/views/splashScreen/screen/screen2.dart';
import 'package:gobox/views/splashScreen/screen/screen3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:gobox/routes/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();
  String buttonText = 'Skip';
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EC),
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (index) {
              currentIndex = index;
              if (index == 2) {
                buttonText = 'Selesai';
              } else {
                buttonText = 'Skip';
              }
              setState(() {});
            },
            children: [Screen1(), Screen2(), Screen3()],
          ),
          Container(
            alignment: const Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoute.login);
                  },
                  child: Text(
                    buttonText,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(),
                SmoothPageIndicator(
                  controller: pageController,
                  count: 3,
                  effect: const WormEffect(
                    activeDotColor: Color(0xFF2E7D32),
                    dotColor: Color(0xFFBDBDBD),
                  ),
                ),
                currentIndex == 2
                    ? const SizedBox(width: 54)
                    : GestureDetector(
                        onTap: () {
                          pageController.nextPage(
                            duration: Duration(microseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: Text(
                          'Lanjut',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
