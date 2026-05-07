import 'dart:async';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() =>
      _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationService _service = NotificationService();

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();
    await _service.fetchServerNotifications();

    _sub = _service.notificationStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = _service.unreadCount;

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            unread > 0
                ? Icons.notifications_active
                : Icons.notifications_none,
            color: Colors.white,
          ),
          onPressed: _openPanel,
        ),

        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                '$unread',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  void _openPanel() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        final list = _service.notifications;

        return Column(
          children: [
            ListTile(
              title: const Text("Notifications"),
              trailing: TextButton(
                onPressed: () async {
                  await _service.markAllAsRead();
                  setState(() {});
                },
                child: const Text("Mark all read"),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final n = list[i];

                  return ListTile(
                    leading: Icon(n.icon, color: n.color),
                    title: Text(n.title),
                    subtitle: Text(n.body),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _service.deleteNotification(n.id);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}