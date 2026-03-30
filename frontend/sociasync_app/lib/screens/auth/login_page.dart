import 'package:flutter/material.dart';
import 'recover_password_page.dart';
import 'sign_up_page.dart';
import '../dashboard/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailErr;
    String? passErr;

    // Validasi email/username
    if (email.isEmpty) {
      emailErr = 'Email/username tidak boleh kosong';
    } else if (email.contains('@') &&
        !RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
      emailErr = 'Format email tidak valid';
    }

    // Validasi password
    if (password.isEmpty) {
      passErr = 'Password tidak boleh kosong';
    } else if (password.length < 6) {
      passErr = 'Password minimal 6 karakter';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loginbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.07),

                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: screenHeight * 0.05),

                // Glass card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Welcome
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D1B4B),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Email label
                        const Text(
                          'Email/username',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2E6E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Email/Username...',
                          obscure: false,
                          hasError: _emailError != null,
                          onChanged: (_) => setState(() => _emailError = null),
                        ),
                        if (_emailError != null) _buildErrorText(_emailError!),

                        const SizedBox(height: 14),

                        // Password label
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2E6E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Password...',
                          obscure: _obscurePassword,
                          hasError: _passwordError != null,
                          onChanged: (_) =>
                              setState(() => _passwordError = null),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade500,
                              size: 18,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        if (_passwordError != null)
                          _buildErrorText(_passwordError!),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RecoverPasswordPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF1A5DC8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_validate()) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardPage(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.25),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.7),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sign up
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(
                                color: Color(0xFFCCDDFF),
                                fontSize: 12,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const SignUpPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF4D4D), size: 13),
          const SizedBox(width: 4),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFFF4D4D),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    bool hasError = false,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasError
              ? const Color(0xFFFF4D4D)
              : Colors.white.withOpacity(0.8),
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontSize: 13,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
