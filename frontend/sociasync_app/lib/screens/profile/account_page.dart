import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/screens/calendar/calendar_week_page.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/auth/login_page.dart';
import 'package:sociasync_app/services/auth_service.dart';
import 'package:sociasync_app/config/api_config.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  bool _isLoadingProfile = true;
  bool _isSavingProfile = false;

  static const List<String> _regions = [
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

  // Data yang bisa diedit
  String name = 'User';
  String email = '-';
  String dateOfBirth = '-';
  String accountRegion = '-';
  String? _profileImageUrl;

  String _formatApiDateToDisplay(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return dateOfBirth;
    }
    const monthNames = [
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
    return '${parsed.day} ${monthNames[parsed.month]} ${parsed.year}';
  }

  String _formatDisplayDateToApi(String value) {
    try {
      final parts = value.split(' ');
      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      final yyyy = int.parse(parts[2]);
      final mm = (months[parts[1]] ?? 1).toString().padLeft(2, '0');
      final dd = int.parse(parts[0]).toString().padLeft(2, '0');
      return '$yyyy-$mm-$dd';
    } catch (_) {
      return '';
    }
  }

  Future<void> _saveProfile(Map<String, dynamic> payload) async {
    if (_isSavingProfile) return;

    setState(() => _isSavingProfile = true);
    try {
      final updated = await AuthService.updateProfile(payload);
      if (!mounted) return;

      setState(() {
        final updatedName = (updated['name'] ?? '').toString().trim();
        final updatedEmail = (updated['email'] ?? '').toString().trim();
        final updatedDob = (updated['date_of_birth'] ?? '').toString().trim();
        final updatedRegion = (updated['region'] ?? '').toString().trim();
        final updatedImage = (updated['profile_image'] ?? '').toString().trim();

        if (updatedName.isNotEmpty) name = updatedName;
        if (updatedEmail.isNotEmpty) email = updatedEmail;
        if (updatedDob.isNotEmpty) {
          dateOfBirth = _formatApiDateToDisplay(updatedDob);
        }
        if (updatedRegion.isNotEmpty) accountRegion = updatedRegion;
        _profileImageUrl = _resolveProfileImageUrl(updatedImage);
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (_isSavingProfile) return;

    setState(() => _isSavingProfile = true);
    try {
      await AuthService.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AuthService.getMe();
      final savedEmail = await AuthService.getSavedEmail();
      if (!mounted) return;

      final loadedName = (profile['name'] ?? '').toString().trim();
      final loadedDob = (profile['date_of_birth'] ?? '').toString().trim();
      final loadedRegion = (profile['region'] ?? '').toString().trim();
      final loadedEmail = (profile['email'] ?? '').toString().trim();
      final loadedProfileImage = (profile['profile_image'] ?? '')
          .toString()
          .trim();

      setState(() {
        if (loadedName.isNotEmpty) name = loadedName;
        if (loadedEmail.isNotEmpty) email = loadedEmail;
        if (savedEmail != null && savedEmail.trim().isNotEmpty) {
          email = savedEmail.trim();
        }
        if (loadedDob.isNotEmpty) {
          dateOfBirth = _formatApiDateToDisplay(loadedDob);
        }
        if (loadedRegion.isNotEmpty) accountRegion = loadedRegion;
        _profileImageUrl = _resolveProfileImageUrl(loadedProfileImage);
        _isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingProfile = false);
    }
  }

  String? _resolveProfileImageUrl(String raw) {
    if (raw.trim().isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    return '${ApiConfig.baseUrl}${raw.startsWith('/') ? raw : '/$raw'}';
  }

  Future<void> _pickAndUploadProfileImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    if (_isSavingProfile) return;
    setState(() => _isSavingProfile = true);
    try {
      final updated = await AuthService.uploadProfileImage(picked);
      if (!mounted) return;
      final updatedImage = (updated['profile_image'] ?? '').toString().trim();
      setState(() {
        _profileImageUrl = _resolveProfileImageUrl(updatedImage);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  void _showAddPhotoPopup() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Text(
                  'Tambah Foto Profil',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadProfileImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadProfileImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Generic popup edit teks biasa ──
  void _showEditDialog({
    required String title,
    required String currentValue,
    required Future<void> Function(String) onSave,
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
              if (!context.mounted) return;
              Navigator.pop(context);
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
    // Parse tanggal saat ini
    DateTime initial;
    try {
      final parts = dateOfBirth.split(' ');
      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      initial = DateTime(
        int.parse(parts[2]),
        months[parts[1]] ?? 1,
        int.parse(parts[0]),
      );
    } catch (_) {
      initial = DateTime(2001, 1, 24);
    }

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
      const monthNames = [
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
      final next = '${picked.day} ${monthNames[picked.month]} ${picked.year}';
      setState(() {
        dateOfBirth = next;
      });
      final apiDate = _formatDisplayDateToApi(next);
      if (apiDate.isNotEmpty) {
        await _saveProfile({'date_of_birth': apiDate});
      }
    }
  }

  // ── Popup Account Region (pilihan dropdown) ──
  void _showRegionPicker() {
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
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _regions.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (_, i) {
              final isSelected = _regions[i] == accountRegion;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                title: Text(
                  _regions[i],
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
                  setState(() => accountRegion = _regions[i]);
                  await _saveProfile({'region': _regions[i]});
                  if (!context.mounted) return;
                  Navigator.pop(context);
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
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur deactivate belum tersedia.'),
                ),
              );
            },
            child: const Text(
              'Deactivate',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
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
              child: _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
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
                                  await _saveProfile({'name': v});
                                },
                              ),
                            ),
                            _buildDivider(),
                            _buildInfoTile(
                              'Email',
                              email,
                              onTap: () => _showEditDialog(
                                title: 'Email',
                                currentValue: email,
                                keyboardType: TextInputType.emailAddress,
                                onSave: (v) async {
                                  await _saveProfile({'email': v});
                                },
                              ),
                            ),
                            _buildDivider(),
                            _buildInfoTile(
                              'Date of birth',
                              dateOfBirth,
                              onTap: _showDatePicker,
                            ),
                            _buildDivider(),
                            _buildInfoTile(
                              'Account Region',
                              accountRegion,
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
                          const SizedBox(height: 100),
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
            height: 160,
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
          bottom: -40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _showAddPhotoPopup,
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
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFDDE8F5),
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 52,
                          color: primaryBlue.withOpacity(0.75),
                        )
                      : null,
                ),
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
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 15,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
