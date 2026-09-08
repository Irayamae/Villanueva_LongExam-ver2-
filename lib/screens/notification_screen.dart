// lib/screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        context.watch<AuthProvider>().user;

    final notifications = [
      _NotificationItem(
        icon: Icons.waving_hand_outlined,
        title: 'Welcome!',
        message:
            'Welcome back, ${user?.firstName ?? 'User'}.',
        time: 'Now',
      ),
      const _NotificationItem(
        icon: Icons.thumb_up_outlined,
        title: 'Stay connected',
        message:
            'Check your feed for the latest posts.',
        time: 'Today',
      ),
      const _NotificationItem(
        icon: Icons.comment_outlined,
        title: 'Join the conversation',
        message:
            'Comment on posts to interact with other users.',
        time: 'Today',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: notifications.length,
      separatorBuilder: (
        context,
        index,
      ) {
        return const SizedBox(height: 8);
      },
      itemBuilder: (
        context,
        index,
      ) {
        final item = notifications[index];

        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: CircleAvatar(
              child: Icon(item.icon),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(
                top: 4,
              ),
              child: Text(item.message),
            ),
            trailing: Text(
              item.time,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ),
        );
      },
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
  });
}