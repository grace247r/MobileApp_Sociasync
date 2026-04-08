import 'package:flutter/material.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';

// Model Data Sederhana
class SavedStrategy {
  final String topic;
  final DateTime date;
  final String category; // Tips, Review, Storytelling
  final int reachEstimation;

  SavedStrategy(this.topic, this.date, this.category, this.reachEstimation);
}

class SavedContentPage extends StatefulWidget {
  const SavedContentPage({super.key});

  @override
  State<SavedContentPage> createState() => _SavedContentPageState();
}

class _SavedContentPageState extends State<SavedContentPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 1;

  // 1. DATA DUMMY
  List<SavedStrategy> allData = [
    SavedStrategy("Street Food Jakarta", DateTime(2026, 3, 15), "Review", 1500),
    SavedStrategy("Tips Reels Viral", DateTime(2026, 1, 10), "Tips", 3000),
    SavedStrategy("Daily Vlog Rina", DateTime(2026, 2, 20), "Story", 1200),
    SavedStrategy(
      "Review Cafe Aesthetic",
      DateTime(2026, 4, 05),
      "Review",
      2500,
    ),
    SavedStrategy("Tutorial Edit CapCut", DateTime(2026, 3, 01), "Tips", 4000),
    SavedStrategy("A Day In My Life", DateTime(2026, 3, 28), "Story", 900),
  ];

  List<SavedStrategy> filteredData = [];
  String searchQuery = "";
  String sortBy = "date"; // default sort by date

  @override
  void initState() {
    super.initState();
    filteredData = List.from(allData);
    _applyFilters();
  }

  // 2. LOGIKA FILTER & SORT
  void _applyFilters() {
    setState(() {
      // Search logic
      filteredData = allData
          .where(
            (item) =>
                item.topic.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();

      // Sort logic
      if (sortBy == "date") {
        filteredData.sort(
          (a, b) => b.date.compareTo(a.date),
        ); // Terbaru ke lama
      } else if (sortBy == "size") {
        filteredData.sort(
          (a, b) => b.reachEstimation.compareTo(a.reachEstimation),
        ); // Reach tertinggi
      }
    });
  }

  // 3. DATE PICKER LOGIC (Filter by Date Range)
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryBlue)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        filteredData = allData
            .where(
              (item) =>
                  item.date.isAfter(
                    picked.start.subtract(const Duration(days: 1)),
                  ) &&
                  item.date.isBefore(picked.end.add(const Duration(days: 1))),
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: DashboardHeader(
                      primaryColor: primaryBlue,
                      onNotificationTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE & DATE FILTER
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: primaryBlue,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Text(
                                'Saved Strategy',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _selectDateRange,
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
                                    children: const [
                                      Text(
                                        'Filter Date',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Icon(
                                        Icons.date_range,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // SEARCH BAR
                          TextField(
                            onChanged: (value) {
                              searchQuery = value;
                              _applyFilters();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search strategy topic...',
                              prefixIcon: Icon(
                                Icons.search,
                                color: primaryBlue.withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // SORT BUTTONS
                          Row(
                            children: [
                              _buildSortChip('Reach (Size)', "size"),
                              const SizedBox(width: 10),
                              _buildSortChip('Latest (Date)', "date"),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // GRID CONTAINER
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: filteredData.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: Text("No strategy found."),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 1.1,
                                        ),
                                    itemCount: filteredData.length,
                                    itemBuilder: (context, index) =>
                                        _buildStrategyItem(filteredData[index]),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // NAVBAR
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavbar(
                selectedIndex: _currentIndex,
                backgroundColor: primaryBlue,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                    );
                  }
                  if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatbotPage()),
                    );
                  }
                  if (index == 3) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER
  Widget _buildSortChip(String label, String value) {
    bool isSelected = sortBy == value;
    return GestureDetector(
      onTap: () {
        sortBy = value;
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryBlue,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyItem(SavedStrategy data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.category,
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.more_vert, size: 14, color: Colors.grey),
            ],
          ),
          const Spacer(),
          Text(
            data.topic,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "${data.date.day}/${data.date.month}/${data.date.year}",
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 12, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                "${data.reachEstimation} Est. Reach",
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
