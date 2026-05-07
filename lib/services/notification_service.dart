import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final StreamController<NotificationData> _controller =
      StreamController.broadcast();

  Stream<NotificationData> get notificationStream =>
      _controller.stream;

  final List<NotificationData> _notifications = [];

  List<NotificationData> get notifications => _notifications;

  // ================= INIT =================
  Future<void> initialize() async {
    if (kIsWeb) {
      try {
        await html.Notification.requestPermission();
      } catch (_) {}
    }
  }

  // ================= LOAD =================
  Future<void> fetchServerNotifications() async {
    if (_notifications.isEmpty) {
      _notifications.addAll([
        NotificationData(
          id: 1,
          title: "Welcome",
          body: "System is ready",
          type: "info",
          timestamp: DateTime.now(),
        ),
        NotificationData(
          id: 2,
          title: "Low Stock",
          body: "Paracetamol is low",
          type: "warning",
          timestamp: DateTime.now(),
        ),
      ]);
    }
  }

  // ================= UNREAD =================
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  // ================= MARK ALL READ =================
  Future<void> markAllAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
  }

  // ================= DELETE =================
  Future<void> deleteNotification(int id) async {
    _notifications.removeWhere((n) => n.id == id);
  }

  // ================= PUSH =================
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String type = "info",
  }) async {
    final notification = NotificationData(
      id: id,
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    _controller.add(notification);

    if (kIsWeb && html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  }

  void dispose() {
    _controller.close();
  }
}