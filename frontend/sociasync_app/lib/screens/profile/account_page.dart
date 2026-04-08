import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/models/user_profile.dart';
import 'package:sociasync_app/services/auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  bool _isLoading = true;
  bool _isSaving = false;

  String name = '-';
  String email = 'Email mengikuti akun login';
  String gender = 'male';
  DateTime? dateOfBirth;
  String accountRegion = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  String get _dateOfBirthLabel {
    if (dateOfBirth == null) return '-';
    final picked = dateOfBirth!;
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${picked.day} ${monthNames[picked.month]} ${picked.year}';
  }

  String get _genderLabel {
    if (gender.isEmpty) return '-';
    return gender[0].toUpperCase() + gender.substring(1);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AuthService.getMe();
      if (!mounted) return;
      setState(() {
        name = profile.name;
        gender = profile.gender;
        dateOfBirth = profile.dateOfBirth;
        accountRegion = profile.region;
        _isLoading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat data akun.')));
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final updated = await AuthService.updateProfile(
        UserProfile(
          name: name,
          gender: gender,
          dateOfBirth: dateOfBirth,
          region: accountRegion,
        ),
      );

      if (!mounted) return;
      setState(() {
        name = updated.name;
        gender = updated.gender;
        dateOfBirth = updated.dateOfBirth;
        accountRegion = updated.region;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan profil.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ── Generic popup edit teks biasa ──
  void _showEditDialog({
    required String title,
    required String currentValue,
    required Future<void> Function(String value) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit $title',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter $title',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await onSave(controller.text.trim());
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Popup khusus Date of Birth (DatePicker) ──
  void _showDatePicker() async {
    final initial = dateOfBirth ?? DateTime(2001, 1, 24);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateOfBirth = picked;
      });
      await _saveProfile();
    }
  }

  // ── Popup Account Region (pilihan dropdown) ──
  void _showRegionPicker() {
    const regions = [
      'Indonesia',
      'Malaysia',
      'Singapore',
      'Thailand',
      'Philippines',
      'Vietnam',
      'United States',
      'United Kingdom',
      'Australia',
      'Japan',
      'South Korea',
    ];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Region',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: regions.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (_, i) {
              final isSelected = regions[i] == accountRegion;
              return ListTile(
                dense: true,
                title: Text(
                  regions[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? primaryBlue : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: primaryBlue, size: 18)
                    : null,
                onTap: () async {
                  setState(() => accountRegion = regions[i]);
                  Navigator.pop(context);
                  await _saveProfile();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showGenderPicker() {
    const values = ['male', 'female'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Gender',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: values.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (_, i) {
              final current = values[i];
              final isSelected = current == gender;
              return ListTile(
                dense: true,
                title: Text(
                  current[0].toUpperCase() + current.substring(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? primaryBlue : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: primaryBlue, size: 18)
                    : null,
                onTap: () async {
                  setState(() => gender = current);
                  Navigator.pop(context);
                  await _saveProfile();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // ── Popup Password ──
  void _showPasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Change Password',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _passwordField(
                controller: oldCtrl,
                label: 'Current Password',
                obscure: obscureOld,
                onToggle: () => setDialogState(() => obscureOld = !obscureOld),
              ),
              const SizedBox(height: 12),
              _passwordField(
                controller: newCtrl,
                label: 'New Password',
                obscure: obscureNew,
                onToggle: () => setDialogState(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 12),
              _passwordField(
                controller: confirmCtrl,
                label: 'Confirm New Password',
                obscure: obscureConfirm,
                onToggle: () =>
                    setDialogState(() => obscureConfirm = !obscureConfirm),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: tambahkan validasi & logic simpan password
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Password updated!'),
                    backgroundColor: primaryBlue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  // ── Popup Deactivate / Delete ──
  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Deactivate or Delete Account',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to deactivate or delete your account? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: logic deactivate
            },
            child: const Text(
              'Deactivate',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: logic delete
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8, left: 2),
                            child: Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          _buildInfoGroup([
                            _buildInfoTile(
                              'Name',
                              name,
                              onTap: () => _showEditDialog(
                                title: 'Name',
                                currentValue: name,
                                onSave: (v) async {
                                  setState(() => name = v);
                                  await _saveProfile();
                                },
                              ),
                            ),
                            _buildDivider(),
                            _buildInfoTile(
                              'Gender',
                              _genderLabel,
                              onTap: _showGenderPicker,
                            ),
                            _buildDivider(),
                            _buildInfoTile('Email', email, onTap: () {}),
                            _buildDivider(),
                            _buildInfoTile(
                              'Date of birth',
                              _dateOfBirthLabel,
                              onTap: _showDatePicker,
                            ),
                            _buildDivider(),
                            _buildInfoTile(
                              'Account Region',
                              accountRegion.isEmpty ? '-' : accountRegion,
                              onTap: _showRegionPicker,
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildSingleTile(
                            'Password',
                            onTap: _showPasswordDialog,
                          ),
                          const SizedBox(height: 16),
                          _buildSingleTile(
                            'Deactivate or delete account',
                            onTap: _showDeactivateDialog,
                            textColor: Colors.red.shade400,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: AppNavbar(
          selectedIndex: 3,
          backgroundColor: primaryBlue,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              return;
            }

            if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CalendarWeekPage()),
              );
              return;
            }

            if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatbotPage()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D5093), Color(0xFF2A6EC5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 8,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Positioned(
          bottom: -45,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/profile.png'),
                backgroundColor: Color(0xFFDDE8F5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleTile(
    String label, {
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
