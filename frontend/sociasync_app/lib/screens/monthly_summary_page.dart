import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';

class MonthlySummaryPage extends StatefulWidget {
  const MonthlySummaryPage({super.key});

  @override
  State<MonthlySummaryPage> createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  final Color primaryBlue = const Color(0xFF1D5093);

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                DashboardHeader(
                  userName: 'Rina',
                  primaryColor: primaryBlue,
                  onNotificationTap: () {},
                ),
                const SizedBox(height: 25),

                const Text(
                  'Monthly Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 20),

                // Chart Container (Besar di Atas)
                Container(
                  height: 220,
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      const Center(
                        child: Text("Line Chart Jan - Jul Placeholder"),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Date Filter Badge (Jan - Jul 2026)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Jan - Jul 2026',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Stats Grid dengan Wadah Biru Transparan
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _buildStatCard('19%', 'Engagement'),
                      _buildStatCard('1,9 M', 'Reach'),
                      _buildStatCard('167 K', 'Followers'),
                      _buildStatCard('457', 'Post'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Section More Insight
                const Text(
                  'More Insight',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 15),

                // Card AI Suggestion
                _buildInsightCard('AI Suggestion', 'Try AI'),
                const SizedBox(height: 12),

                // Card Boost Insight
                _buildInsightCard('Boost Insight', 'Try Now'),

                const SizedBox(height: 100), // Spasi Navbar
              ],
            ),
          ),

          // Navbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppNavbar(
              selectedIndex: 1, // Index History/Summary
              backgroundColor: primaryBlue,
              onTap: (index) {},
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Stats (Sama seperti Dashboard)
  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B67C0),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF535353),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Insight Row (AI Suggestion / Boost)
  Widget _buildInsightCard(String title, String btnLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF535353),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(
              btnLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
