import 'package:flutter/material.dart';
import '../../controllers/auth.dart';
import 'package:gobox/views/widgets/form_auth.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final AuthController _authController = AuthController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatUser = TextEditingController();

  String message = '';
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    const Color darkGrey = Color(0xFF616161);
    return Scaffold(

      body: Stack(
        children:[
          Positioned.fill(
            child: Image.asset(
              'asset/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Akun GoBox',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Buat akun baru untuk mulai menggunakan layanan GoBox.',
                  style: const TextStyle(fontSize: 16, color: darkGrey),
                ),
                const SizedBox(height: 30),

                GoBoxTextField(
                  controller: _usernameController,
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 30),
                GoBoxTextField(
                  controller: _alamatUser,
                  labelText: 'Alamat',
                  hintText: 'Masukkan alamat anda',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 30),

                GoBoxElevatedButton(
                  text: 'Daftar',
                  onPressed: () async {
                    final result = await _authController.signUp(
                      _usernameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _alamatUser.text,
                      context,
                    );
                    setState(() => message = result);

                    if (result.contains('berhasil')) {
                      await Future.delayed(const Duration(seconds: 2));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Link "Masuk di sini" (Reusable)
                GoBoxTextLink(
                  text: 'Sudah punya akun? Masuk di sini',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 20),

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