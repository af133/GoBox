import 'package:flutter/material.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/splass.png', fit: BoxFit.cover),

          Center(
            child: FractionallySizedBox(
              widthFactor: 0.73,
              child: Image.asset(
                'assets/splashscreen.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          /// App Name
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Boxly',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black54,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
