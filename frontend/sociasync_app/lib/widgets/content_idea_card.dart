import 'package:flutter/material.dart';

class ContentIdeaCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final String description;
  final String emoji;
  final Color primaryColor;

  const ContentIdeaCard({
    super.key,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.emoji,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Efek transparan agar background lingkaran tetap terlihat
        color: const Color(0xFFE8EEFF).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Judul dengan Dot
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Baris Badge (Emoji + Teks Opportunity/Driver)
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                badgeText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Teks Deskripsi
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: primaryColor.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          // Tombol Generate Script
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFA6B7FF,
                  ), // Warna ungu muda tombol
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Generate Script',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
