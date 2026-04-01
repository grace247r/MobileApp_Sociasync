import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dashboard/dashboard_page.dart';
import 'sign_up_page.dart'; // ← tambahkan import ini

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  String? _emailError;
  String? _codeError;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    String? emailErr;
    String? codeErr;

    // Validasi email
    if (email.isEmpty) {
      emailErr = 'Email/username tidak boleh kosong';
    } else if (email.contains('@') &&
        !RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
      emailErr = 'Format email tidak valid';
    }

    // Validasi code — harus integer, tidak boleh kosong
    if (code.isEmpty) {
      codeErr = 'Kode tidak boleh kosong';
    } else if (!RegExp(r'^\d+$').hasMatch(code)) {
      codeErr = 'Kode harus berupa angka, bukan huruf';
    }

    setState(() {
      _emailError = emailErr;
      _codeError = codeErr;
    });

    return emailErr == null && codeErr == null;
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
                        // Title
                        const Text(
                          'Reset Password',
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
                          hasError: _emailError != null,
                          onChanged: (_) => setState(() => _emailError = null),
                        ),
                        if (_emailError != null) _buildErrorText(_emailError!),

                        const SizedBox(height: 14),

                        // Code label
                        const Text(
                          'Code',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2E6E),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Code field with Send Code button inside
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _codeError != null
                                  ? const Color(0xFFFF4D4D)
                                  : Colors.white.withOpacity(0.8),
                              width: _codeError != null ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeController,
                                  // Hanya angka yang bisa diketik
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) =>
                                      setState(() => _codeError = null),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Code......',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              // Send Code button
                              GestureDetector(
                                onTap: () {
                                  // TODO: send code logic
                                },
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1A3EC8),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Send Code',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_codeError != null) _buildErrorText(_codeError!),

                        // Didn't get a code?
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Didn't get a code?",
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

                        // Sign up — navigasi ke SignUpPage
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
                                      // ← navigasi ke SignUpPage
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
    bool hasError = false,
    ValueChanged<String>? onChanged,
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
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontSize: 13,
          ),
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
