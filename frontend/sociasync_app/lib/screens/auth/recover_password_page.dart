import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociasync_app/services/auth_service.dart';
import 'login_page.dart';
import 'sign_up_page.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSendingCode = false;
  bool _isSubmitting = false;

  String? _emailError;
  String? _codeError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? emailErr;
    String? codeErr;
    String? newPasswordErr;
    String? confirmPasswordErr;

    if (email.isEmpty) {
      emailErr = 'Email/username tidak boleh kosong';
    } else if (email.contains('@') &&
        !RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
      emailErr = 'Format email tidak valid';
    }

    if (code.isEmpty) {
      codeErr = 'Kode tidak boleh kosong';
    } else if (!RegExp(r'^\d+$').hasMatch(code)) {
      codeErr = 'Kode harus berupa angka';
    } else if (code.length != 6) {
      codeErr = 'Kode harus 6 digit';
    }

    if (newPassword.isEmpty) {
      newPasswordErr = 'Password baru tidak boleh kosong';
    } else if (newPassword.length < 8) {
      newPasswordErr = 'Password minimal 8 karakter';
    }

    if (confirmPassword != newPassword) {
      confirmPasswordErr = 'Konfirmasi password tidak cocok';
    }

    setState(() {
      _emailError = emailErr;
      _codeError = codeErr;
      _newPasswordError = newPasswordErr;
      _confirmPasswordError = confirmPasswordErr;
    });

    return emailErr == null &&
        codeErr == null &&
        newPasswordErr == null &&
        confirmPasswordErr == null;
  }

  Future<void> _sendCode() async {
    final identifier = _emailController.text.trim();
    if (identifier.isEmpty) {
      setState(() => _emailError = 'Email/username tidak boleh kosong');
      return;
    }
    if (_isSendingCode) return;

    setState(() => _isSendingCode = true);
    try {
      await AuthService.requestPasswordResetCode(identifier: identifier);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode berhasil dikirim ke email kamu.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim kode: $e')));
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  Future<void> _submitResetPassword() async {
    if (!_validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await AuthService.confirmPasswordReset(
        identifier: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil direset. Silakan login.'),
        ),
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal reset password: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                Image.asset('assets/logo.png', width: 140, height: 140),
                SizedBox(height: screenHeight * 0.03),

                // Glass card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D1B4B),
                        ),
                      ),
                      const SizedBox(height: 18),

                      _label('Email/username'),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email/Username...',
                        keyboardType: TextInputType.emailAddress,
                        hasError: _emailError != null,
                        onChanged: (_) => setState(() => _emailError = null),
                      ),
                      if (_emailError != null) _buildErrorText(_emailError!),

                      const SizedBox(height: 14),

                      _label('Code'),
                      _buildCodeField(), // Perbaikan layout di sini
                      if (_codeError != null) _buildErrorText(_codeError!),

                      const SizedBox(height: 14),

                      _label('New Password'),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        hint: 'New password...',
                        obscure: _obscureNewPassword,
                        hasError: _newPasswordError != null,
                        onToggle: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword,
                        ),
                        onChanged: (_) =>
                            setState(() => _newPasswordError = null),
                      ),
                      if (_newPasswordError != null)
                        _buildErrorText(_newPasswordError!),

                      const SizedBox(height: 14),

                      _label('Confirm New Password'),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm new password...',
                        obscure: _obscureConfirmPassword,
                        hasError: _confirmPasswordError != null,
                        onToggle: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        onChanged: (_) =>
                            setState(() => _confirmPasswordError = null),
                      ),
                      if (_confirmPasswordError != null)
                        _buildErrorText(_confirmPasswordError!),

                      const SizedBox(height: 20),

                      _buildSubmitButton(),

                      const SizedBox(height: 16),
                      _buildSignUpLink(),
                    ],
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

  // Widget Helper biar kode utama gak kepanjangan
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A2E6E),
        ),
      ),
    );
  }

  Widget _buildCodeField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _codeError != null
              ? Colors.red
              : Colors.white.withOpacity(0.8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: (_) => setState(() => _codeError = null),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: '6-digit code',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
          GestureDetector(
            onTap: _isSendingCode ? null : _sendCode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF1A3EC8,
                ).withOpacity(_isSendingCode ? 0.6 : 1.0),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: _isSendingCode
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Send Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.25),
          foregroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(color: Colors.white.withOpacity(0.7), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SignUpPage())),
        child: RichText(
          text: const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Color(0xFF1A2E6E), fontSize: 12),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Common TextFields & Errors
  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 11),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasError ? Colors.red : Colors.white.withOpacity(0.8),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasError ? Colors.red : Colors.white.withOpacity(0.8),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
