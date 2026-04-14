import 'package:flutter/material.dart';
import 'package:sociasync_app/services/content_generator_service.dart';
import 'package:sociasync_app/widgets/app_background_wrapper.dart';
import 'package:sociasync_app/widgets/app_navbar.dart';
import 'package:sociasync_app/widgets/dashboard_header.dart';
import 'package:sociasync_app/widgets/date_range_picker_dialog.dart'
    as date_picker;
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/chatbot_AI/chatbot.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';
import 'package:sociasync_app/screens/dashboard/notification_page.dart';

class SavedStrategy {
  final String topic;
  final String ideaTitle;
  final DateTime date;
  final String platform;

  SavedStrategy({
    required this.topic,
    required this.ideaTitle,
    required this.date,
    required this.platform,
  });
}

class SavedContentPage extends StatefulWidget {
  const SavedContentPage({super.key});

  @override
  State<SavedContentPage> createState() => _SavedContentPageState();
}

class _SavedContentPageState extends State<SavedContentPage> {
  final Color primaryBlue = const Color(0xFF1D5093);
  final int _currentIndex = 1;

  List<SavedStrategy> allData = const <SavedStrategy>[];
  List<SavedStrategy> filteredData = const <SavedStrategy>[];
  String searchQuery = '';
  String sortBy = 'date';
  bool _isLoading = true;

  DateTime? _filterStart;
  DateTime? _filterEnd;

  @override
  void initState() {
    super.initState();
    _loadSavedContent();
  }

  Future<void> _loadSavedContent() async {
    setState(() => _isLoading = true);
    try {
      final result = await ContentGeneratorService.getSavedContents();
      final parsed = result.map((item) {
        final created = DateTime.tryParse(
          (item['created_at'] ?? '').toString(),
        );
        final idea = item['idea'] is Map
            ? Map<String, dynamic>.from(item['idea'] as Map)
            : <String, dynamic>{};

        return SavedStrategy(
          topic: (item['topic'] ?? '-').toString(),
          ideaTitle: (idea['title'] ?? '-').toString(),
          date: created ?? DateTime.now(),
          platform: (item['platform'] ?? '-').toString(),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        allData = parsed;
        _isLoading = false;
      });
      _applyFilters();
    } on ContentGeneratorServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        allData = const <SavedStrategy>[];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _applyFilters() {
    setState(() {
      filteredData = allData.where((item) {
        final matchSearch =
            item.topic.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.ideaTitle.toLowerCase().contains(searchQuery.toLowerCase());

        if (!matchSearch) return false;
        if (_filterStart == null || _filterEnd == null) return true;

        return item.date.isAfter(
              _filterStart!.subtract(const Duration(days: 1)),
            ) &&
            item.date.isBefore(_filterEnd!.add(const Duration(days: 1)));
      }).toList();

      if (sortBy == 'date') {
        filteredData.sort((a, b) => b.date.compareTo(a.date));
      } else {
        filteredData.sort((a, b) => a.platform.compareTo(b.platform));
      }
    });
  }

  void _selectDateRange() {
    showDialog(
      context: context,
      builder: (context) {
        return date_picker.CustomDateRangeDialog(
          primaryColor: primaryBlue,
          initialStartDate: _filterStart,
          initialEndDate: _filterEnd,
          onApply: (startDate, endDate) {
            _filterStart = startDate;
            _filterEnd = endDate;
            _applyFilters();
          },
        );
      },
    );
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: DashboardHeader(
                      userName: 'Rina',
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
                          Row(
                            children: [
                              _buildSortChip('Platform', 'platform'),
                              const SizedBox(width: 10),
                              _buildSortChip('Latest (Date)', 'date'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: _isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                      ),
                                    ),
                                  )
                                : filteredData.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: Text('No strategy found.'),
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
          ],
        ),
        bottomNavigationBar: AppNavbar(
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
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = sortBy == value;
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
                  data.platform,
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.bookmark_rounded, size: 14, color: Colors.grey),
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
            data.ideaTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const Divider(),
          Text(
            '${data.date.day}/${data.date.month}/${data.date.year}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
