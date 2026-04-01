import 'package:flutter/material.dart';
import 'login_page.dart';
import '../dashboard/dashboard_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = '';

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _genderError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? nameErr;
    String? emailErr;
    String? genderErr;
    String? passwordErr;
    String? confirmPasswordErr;

    // Validasi nama
    if (name.isEmpty) {
      nameErr = 'Nama tidak boleh kosong';
    } else if (name.length < 2) {
      nameErr = 'Nama minimal 2 karakter';
    } else if (!RegExp(r"^[a-zA-Z\s'.-]+$").hasMatch(name)) {
      nameErr = 'Nama hanya boleh berisi huruf';
    }

    // Validasi email
    if (email.isEmpty) {
      emailErr = 'Email tidak boleh kosong';
    } else if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
      emailErr = 'Format email tidak valid';
    }

    // Validasi gender
    if (_selectedGender.isEmpty) {
      genderErr = 'Pilih jenis kelamin';
    }

    // Validasi password
    if (password.isEmpty) {
      passwordErr = 'Password tidak boleh kosong';
    } else if (password.length < 8) {
      passwordErr = 'Password minimal 8 karakter';
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      passwordErr = 'Password harus mengandung minimal 1 huruf kapital';
    } else if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      passwordErr = 'Password harus mengandung minimal 1 angka';
    }

    // Validasi konfirmasi password
    if (confirmPassword.isEmpty) {
      confirmPasswordErr = 'Konfirmasi password tidak boleh kosong';
    } else if (confirmPassword != password) {
      confirmPasswordErr = 'Password tidak cocok';
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _genderError = genderErr;
      _passwordError = passwordErr;
      _confirmPasswordError = confirmPasswordErr;
    });

    return nameErr == null &&
        emailErr == null &&
        genderErr == null &&
        passwordErr == null &&
        confirmPasswordErr == null;
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
                SizedBox(height: screenHeight * 0.05),

                // Logo
                Image.asset(
                  'assets/logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: screenHeight * 0.03),

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
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0D1B4B),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Name
                        _buildLabel('Name'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Name.....',
                          hasError: _nameError != null,
                          onChanged: (_) => setState(() => _nameError = null),
                        ),
                        if (_nameError != null) _buildErrorText(_nameError!),

                        const SizedBox(height: 14),

                        // Email
                        _buildLabel('Email'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Email......',
                          keyboardType: TextInputType.emailAddress,
                          hasError: _emailError != null,
                          onChanged: (_) => setState(() => _emailError = null),
                        ),
                        if (_emailError != null) _buildErrorText(_emailError!),

                        const SizedBox(height: 14),

                        // Gender
                        _buildLabel('Gender'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildGenderButton('Male')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildGenderButton('Female')),
                          ],
                        ),
                        if (_genderError != null)
                          _buildErrorText(_genderError!),

                        const SizedBox(height: 14),

                        // Password
                        _buildLabel('Password'),
                        const SizedBox(height: 6),
                        _buildPasswordField(
                          controller: _passwordController,
                          hint: 'Password......',
                          obscure: _obscurePassword,
                          hasError: _passwordError != null,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onChanged: (_) =>
                              setState(() => _passwordError = null),
                        ),
                        if (_passwordError != null)
                          _buildErrorText(_passwordError!),

                        const SizedBox(height: 14),

                        // Confirmation Password
                        _buildLabel('Confirmation Password'),
                        const SizedBox(height: 6),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: 'Password......',
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

                        // Sign Up button
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
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Have an account? Log In
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Have an account? ',
                              style: const TextStyle(
                                color: Color(0xFFCCDDFF),
                                fontSize: 12,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Log In',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A2E6E),
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
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFF4D4D),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    final hasError = _genderError != null;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedGender = gender;
        _genderError = null;
      }),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.55)
              : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasError
                ? const Color(0xFFFF4D4D)
                : isSelected
                ? Colors.white.withOpacity(0.9)
                : Colors.white.withOpacity(0.5),
            width: hasError ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          gender,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF0D1B4B)
                : const Color(0xFF1A2E6E).withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool hasError = false,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
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
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey.shade500,
              size: 18,
            ),
            onPressed: onToggle,
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
