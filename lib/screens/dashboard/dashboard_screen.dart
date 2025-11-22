import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../utils/constants.dart';
import '../main_features/upload_document_screen.dart';
import '../main_features/dtr_screen.dart';
import '../main_features/daily_journal_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hasUnreadNotifications = false;

  Map<String, dynamic> get user => widget.user;

  @override
  void initState() {
    super.initState();
    _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.notificationsEndpoint}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        bool hasUnread = false;
        Iterable<dynamic>? listSource;
        if (decoded is List) {
          listSource = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['notifications'] is List) {
          listSource = decoded['notifications'] as List<dynamic>;
        }

        if (listSource != null) {
          hasUnread = listSource.any((item) {
            if (item is Map<String, dynamic>) {
              final dynamic status = item['status'] ?? item['is_read'] ?? item['read'];
              if (status is bool) {
                return status == false;
              }
              if (status is String) {
                return !(status.toLowerCase() == 'read' || status == '1');
              }
            }
            return true; // treat unknown as unread
          });
        }

        if (mounted) {
          setState(() {
            _hasUnreadNotifications = hasUnread;
          });
        }
      }
    } catch (_) {
      // Fail silently; notifications are non-critical.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          _buildNotificationIcon(context),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user['username'] ?? 'Student'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${user['email']}'),
                    Text('Role: ${user['role']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardItem(
                  icon: Icons.person,
                  title: 'Profile',
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to profile screen
                  },
                ),
                _buildDashboardItem(
                  icon: Icons.description,
                  title: 'Documents',
                  color: Colors.green,
                  onTap: () {
                    // Navigate to documents screen
                  },
                ),
                _buildDashboardItem(
                  icon: Icons.announcement,
                  title: 'Announcements',
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to announcements screen
                  },
                ),
                _buildDashboardItem(
                  icon: Icons.timer,
                  title: 'OJT Hours',
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to hours tracking screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () async {
        await Navigator.pushNamed(context, NotificationsScreen.routeName);
        // Re-check notifications when returning from the notifications page
        if (mounted) {
          _checkNotifications();
        }
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (_hasUnreadNotifications)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final String displayName = (user['username'] ?? user['name'] ?? 'Student').toString();
    final String displayId = (user['student_id'] ?? 'ID: 000000').toString();

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayId,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.upload_file,
            title: 'Upload Document',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, UploadDocumentScreen.routeName);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.access_time,
            title: 'Daily Time Record (DTR)',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, DtrScreen.routeName);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.book_outlined,
            title: 'Daily Journal',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, DailyJournalScreen.routeName);
            },
          ),
          const Spacer(),
          const Divider(height: 1),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: 'Log out',
            onTap: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey.shade700),
      title: Text(title),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDashboardItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}