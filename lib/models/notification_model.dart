import 'package:flutter/material.dart';

class NotificationData {
  final int id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? data;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.data,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'info',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      actionUrl: json['action_url'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'created_at': timestamp.toIso8601String(),
      'is_read': isRead,
      'action_url': actionUrl,
      'data': data,
    };
  }

  // ================= UI HELPERS =================

  Color get color {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
        return Colors.blue;
      case 'sale':
        return Colors.green;
      case 'stock':
        return Colors.orange;
      case 'prescription':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      case 'sale':
        return Icons.shopping_cart;
      case 'stock':
        return Icons.inventory;
      case 'prescription':
        return Icons.medical_services;
      default:
        return Icons.notifications;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);

    if (diff.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}