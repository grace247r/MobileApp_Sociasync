import 'package:flutter/material.dart';
import 'package:sociasync_app/services/tiktok_service.dart';

Future<bool> showTikTokManageAccountDialog({
  required BuildContext context,
  required String initialUsername,
  required Color primaryColor,
}) async {
  final usernameController = TextEditingController(text: initialUsername);
  var isSubmitting = false;
  String? dialogError;

  try {
    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manage TikTok'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: usernameController,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Username TikTok',
                      hintText: '@username',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      dialogError!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final username = usernameController.text.trim();
                          if (username.isEmpty) {
                            setDialogState(() {
                              dialogError = 'Username TikTok wajib diisi.';
                            });
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });

                          try {
                            await TikTokService.connectUsername(username);
                            if (!context.mounted) return;
                            Navigator.of(dialogContext).pop(true);
                          } on TikTokServiceException catch (e) {
                            setDialogState(() {
                              dialogError = e.message;
                              isSubmitting = false;
                            });
                          } catch (_) {
                            setDialogState(() {
                              dialogError = 'Gagal menyimpan username TikTok.';
                              isSubmitting = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    return updated == true;
  } finally {
    usernameController.dispose();
  }
}
