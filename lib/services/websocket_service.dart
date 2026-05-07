// lib/services/websocket_service.dart

import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance {
    _instance ??= WebSocketService._internal();
    return _instance!;
  }
  
  WebSocketService._internal();
  
  WebSocketChannel? _channel;
  final List<void Function(Map<String, dynamic>)> _listeners = [];
  bool _isConnected = false;
  
  bool get isConnected => _isConnected;
  
  void connect() {
    try {
      final wsUrl = Uri.parse('ws://127.0.0.1:8000/ws/dashboard/');
      _channel = WebSocketChannel.connect(wsUrl);
      
      _channel!.stream.listen((message) {
        try {
          final data = jsonDecode(message);
          for (var listener in _listeners) {
            listener(data);
          }
        } catch (e) {
          debugPrint('Error parsing WebSocket message: $e');
        }
      }, onDone: () {
        _isConnected = false;
        debugPrint('WebSocket disconnected');
        // Attempt to reconnect after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (!_isConnected) {
            connect();
          }
        });
      }, onError: (error) {
        _isConnected = false;
        debugPrint('WebSocket error: $error');
        Future.delayed(const Duration(seconds: 3), () {
          if (!_isConnected) {
            connect();
          }
        });
      });
      
      _isConnected = true;
      debugPrint('WebSocket connected');
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
      Future.delayed(const Duration(seconds: 3), () {
        connect();
      });
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }
  
  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  void addListener(void Function(Map<String, dynamic>) listener) {
    _listeners.add(listener);
  }
  
  void removeListener(void Function(Map<String, dynamic>) listener) {
    _listeners.remove(listener);
  }
  
  void refreshDashboard() {
    sendMessage({'action': 'refresh'});
  }
  
  void getChartData(String period) {
    sendMessage({'action': 'get_chart_data', 'period': period});
  }
}