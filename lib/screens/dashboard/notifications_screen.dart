import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/notifications';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  String? _error;
  List<_NotificationItem> _items = <_NotificationItem>[];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.notificationsEndpoint}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<_NotificationItem> items = <_NotificationItem>[];

        if (decoded is List) {
          for (final entry in decoded) {
            if (entry is Map<String, dynamic>) {
              items.add(_NotificationItem.fromJson(entry));
            }
          }
        } else if (decoded is Map<String, dynamic> && decoded['notifications'] is List) {
          for (final entry in decoded['notifications'] as List<dynamic>) {
            if (entry is Map<String, dynamic>) {
              items.add(_NotificationItem.fromJson(entry));
            }
          }
        }

        setState(() {
          _items = items;
        });
      } else {
        setState(() {
          _error = 'Failed to load notifications (${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading notifications: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool get _hasUnread => _items.any((item) => !item.isRead);

  void _markAsRead(int index) {
    setState(() {
      _items[index] = _items[index].copyWith(isRead: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 24),
          Center(child: Text(_error!)),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _fetchNotifications,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 24),
          Center(child: Text('No notifications yet.')),
        ],
      );
    }

    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          onTap: () {
            if (!item.isRead) {
              _markAsRead(index);
            }
          },
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                item.timestamp,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      },
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String timestamp;
  final bool isRead;

  const _NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  factory _NotificationItem.fromJson(Map<String, dynamic> json) {
    final dynamic status = json['status'] ?? json['is_read'] ?? json['read'];
    final bool isRead;
    if (status is bool) {
      isRead = status;
    } else if (status is String) {
      isRead = status.toLowerCase() == 'read' || status == '1';
    } else {
      isRead = false;
    }

    return _NotificationItem(
      title: (json['title'] ?? 'Notification').toString(),
      message: (json['message'] ?? json['description'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? json['created_at'] ?? '').toString(),
      isRead: isRead,
    );
  }

  _NotificationItem copyWith({bool? isRead}) {
    return _NotificationItem(
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
