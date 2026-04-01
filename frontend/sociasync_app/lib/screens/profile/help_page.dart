import 'package:flutter/material.dart';
import 'package:sociasync_app/screens/dashboard/dashboard_page.dart';
import 'package:sociasync_app/screens/profile/profile_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  final Color primaryBlue = const Color(0xFF1D5093);

  // Konten tiap topik help
  static const Map<String, String> _helpContent = {
    'Account growth': '''Growing your account on SociaSync takes consistency and strategy. Here are some tips:

• Post regularly — aim for at least 3–5 times per week.
• Use relevant hashtags to increase discoverability.
• Engage with your audience by replying to comments and messages.
• Collaborate with other creators in your niche.
• Analyze your weekly chart on the dashboard to find out when your audience is most active.
• Optimize your profile bio with clear keywords about your content.
• Share your posts across multiple platforms (TikTok, Instagram) using the Connect feature.

Consistency is key. Accounts that post regularly see up to 3x more engagement than those that post sporadically.''',

    'Your account status': '''Your account status indicates the health and standing of your SociaSync account.

Account statuses:
• Active — Your account is in good standing.
• Restricted — Some features may be limited due to policy violations.
• Suspended — Your account has been temporarily disabled.
• Deactivated — Your account has been deactivated by you.

How to check your status:
Go to Profile → Account → Account Region to see your regional compliance status.

If your account is restricted or suspended, please contact our support team at support@sociasync.com with your account email and a description of the issue.

Appeals are reviewed within 3–5 business days.''',

    'Account safety': '''Keeping your SociaSync account safe is our top priority. Follow these best practices:

Passwords:
• Use a strong password with at least 8 characters, including uppercase, lowercase, numbers, and symbols.
• Change your password every 3–6 months.
• Never share your password with anyone.

Login security:
• Always log out when using shared devices.
• Be cautious of phishing emails pretending to be from SociaSync.

Suspicious activity:
• If you notice unusual login activity, change your password immediately.
• Contact support if you believe your account has been compromised.

Privacy settings:
• Set your account to Private to control who sees your content.
• Review your blocked accounts list regularly.''',

    'Updating name': '''You can update your display name at any time from your account settings.

Steps to update your name:
1. Go to Profile → Account.
2. Tap on "Name".
3. A dialog will appear — clear the current name and type your new one.
4. Tap "Save" to confirm.

Important notes:
• Your name can be changed at any time with no limit.
• Your name is visible to all users unless your account is set to Private.
• Changing your name does not affect your account data or followers.
• Names must be between 2–50 characters.
• Special characters are allowed, but avoid misleading or offensive names.''',

    'Forgot my password': '''If you forgot your password, you can reset it easily.

Steps to reset your password:
1. On the login screen, tap "Forgot Password".
2. Enter the email address linked to your account.
3. Check your email for a password reset link (check spam/junk if not received).
4. Click the link and enter your new password.
5. Log in with your new password.

Tips:
• The reset link expires after 30 minutes — request a new one if needed.
• Make sure you have access to the email you registered with.
• If you no longer have access to your email, contact support@sociasync.com.

Already logged in but want to change your password?
Go to Profile → Account → Password.''',

    'Editing, posting, and deleting': '''Managing your content on SociaSync is simple.

Posting content:
• Tap the "+ Generate" button on the Dashboard to create a new post.
• Add your caption, hashtags, and choose your platform (TikTok/Instagram).
• Schedule or post immediately.

Editing a post:
• Go to your post history.
• Tap the post you want to edit.
• Make your changes and tap "Update".

Note: Editing a post that has already been published will re-publish it with the new content.

Deleting a post:
• Go to your post history.
• Swipe left on the post or tap the options menu.
• Select "Delete" and confirm.

Important: Deleted posts cannot be recovered. Make sure you want to permanently remove the content before confirming.''',

    'Searching for content': '''SociaSync makes it easy to find content and inspiration.

How to search:
• Use the search bar at the top of the Explore screen.
• Search by keywords, hashtags, or creator names.

Filtering results:
• Filter by content type: videos, images, or text posts.
• Filter by date: newest first or most popular.
• Filter by platform: TikTok or Instagram.

Finding trending content:
• Check the "Best Performing Post" section on your Dashboard.
• Browse trending hashtags in the Explore tab.

Tips for better search results:
• Use specific keywords related to your niche.
• Search hashtags with "#" prefix (e.g., #foodvlog).
• Save posts you like by tapping the bookmark icon.''',

    'Unable to follow a user': '''If you are having trouble following a user, here are some possible reasons and solutions:

Possible reasons:

1. The user has a private account.
   → Send a follow request and wait for them to approve it.

2. The user has blocked you.
   → You will not be able to follow or view their content.

3. You have been restricted by the user.
   → Some interactions may be limited.

4. You have reached the follow limit.
   → SociaSync allows a maximum of 5,000 follows. Unfollow some accounts to continue.

5. Network issue.
   → Check your internet connection and try again.

6. App bug or glitch.
   → Try closing and reopening the app. If the problem persists, clear the app cache or reinstall.

Still having issues? Contact us at support@sociasync.com with the username you are trying to follow.''',
  };

  void _showHelpDialog(BuildContext context, String topic) {
    final content = _helpContent[topic] ?? 'Content coming soon.';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      topic,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D5093),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 8),

              // Scrollable content
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D5093),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Got it', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topics = _helpContent.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'How can we help?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of help topics (no group card, individual rows)
                  ...topics.map((topic) => _buildHelpTile(context, topic)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
                (route) => false,
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 30),
            ),
            const Icon(Icons.history, color: Colors.white, size: 30),
            const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
            GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
                (route) => false,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ],
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
                'Profile',
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
      ],
    );
  }

  Widget _buildHelpTile(BuildContext context, String topic) {
    return InkWell(
      onTap: () => _showHelpDialog(context, topic),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                topic,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10,
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