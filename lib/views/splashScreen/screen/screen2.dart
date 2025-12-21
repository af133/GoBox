import 'package:flutter/material.dart';

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/onboarding_icon_2.png'),
        const SizedBox(height: 20),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Penyimpanan Teraman & Termurah',
            style: TextStyle(
              color: Color.fromARGB(226, 0, 0, 0),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'lorem ipsum lorem ipsumlorem ipsumlorem ipsumlorem ipsumlorem ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color.fromARGB(182, 0, 0, 0),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
