import 'package:flutter/material.dart';

class SuccessSaveDialog extends StatelessWidget {
  const SuccessSaveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1D5093);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(
          color: primaryBlue,
          width: 2,
        ), // Outline biru sesuai gambar
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Success',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Content Succesfully Saved !',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
