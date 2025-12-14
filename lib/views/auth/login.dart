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
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'asset/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                Center(
                  child: SizedBox(
                    height: 200,
                    child: Image.asset('asset/logo.png'),
                  ),
                ),

                const SizedBox(height: 20),

                GoBoxTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'contoh@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 20),

                GoBoxElevatedButton(
                  text: 'Masuk',
                  onPressed: () async {
                    final result = await _authController.login(
                      _emailController.text,
                      _passwordController.text,
                    );

                    setState(() => message = result);
                    if (result.contains('berhasil')) {
                      await Future.delayed(const Duration(seconds: 1));
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Dashboard(),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 15),

                GoBoxTextLink(
                  text: 'Belum punya akun? Daftar sekarang',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignUpView(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 5),

                if (message.isNotEmpty && message != 'berhasil')
                  AuthMessage(message: message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
