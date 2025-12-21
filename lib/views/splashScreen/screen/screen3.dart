import 'package:flutter/material.dart';

class Screen3 extends StatelessWidget {
  const Screen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/onboarding_screen_3.png'),
        const SizedBox(height: 20),
        const Text(
          'Pelayanan Tingkat Global',
          style: TextStyle(
            color: Color.fromARGB(226, 0, 0, 0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
