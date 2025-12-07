import 'package:flutter/material.dart';
import '../../controllers/auth.dart';
import 'signup.dart';
import '../dashboard.dart';
import 'package:gobox/views/widgets/form_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String message = '';
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    const Color darkGrey = Color(0xFF616161);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            Center(
              child: SizedBox(
                height: 200,
                child: Image.asset('asset/logo.png'),
              ),
            ),
            const SizedBox(height: 40),

            // Judul
            const Text(
              'Masuk ke Akun Anda',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Masukkan email dan password Anda untuk melanjutkan.',
              style: TextStyle(
                fontSize: 16,
                color: darkGrey,
              ),
            ),
            const SizedBox(height: 30),

            // TextField Email
            GoBoxTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'contoh@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // TextField Password
            GoBoxTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Minimal 8 karakter',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureText,
              onToggleVisibility: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            const SizedBox(height: 30),

            // Tombol Login
            GoBoxElevatedButton(
              text: 'Masuk',
              onPressed: () async {
                final result = await _authController.login(
                  _emailController.text,
                  _passwordController.text,
                );

                setState(() => message = result);

                // ✅ Jika login berhasil, langsung ke HomePage
                if (result.contains('berhasil')) {
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (_) => const Dashboard()),
                      
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),

            // Link ke halaman SignUp
            GoBoxTextLink(
              text: 'Belum punya akun? Daftar sekarang',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpView()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Pesan error / sukses
            if (message.isNotEmpty && message != 'berhasil')
              AuthMessage(message: message),
          ],
        ),
      ),
    );
  }
}
