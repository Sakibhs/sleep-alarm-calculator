import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AlarmService {
  static const _channel = MethodChannel('sleep_calculator/alarm');

  Future<void> setAlarm(DateTime time) async {
    if (Platform.isAndroid) {
      await _setAndroidAlarm(time);
    } else if (Platform.isIOS) {
      _showIOSNote(time);
    }
  }

  Future<void> _setAndroidAlarm(DateTime time) async {
    try {
      final result = await _channel.invokeMethod<String>('openDefaultAlarm', {
        'hour': time.hour,
        'minute': time.minute,
        'label': 'Sleep Alarm',
      });

      if (result == 'opened_launcher') {
        // Clock app opened but alarm extras not supported — tell user the time
        _showManualSetNote(time);
      } else if (result == 'not_found') {
        _showNotFoundError(time);
      }
      // 'opened' → clock app showing with time pre-filled, no extra message needed
    } on PlatformException {
      _showNotFoundError(time);
    }
  }

  void _showManualSetNote(DateTime time) {
    final label = DateFormat('hh:mm a').format(time);
    Get.snackbar(
      'Clock app opened',
      'Please set your alarm for $label',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      backgroundColor: const Color(0xFF1A2235),
      colorText: Colors.white,
      icon: const Icon(Icons.alarm_rounded, color: Color(0xFF818CF8)),
    );
  }

  void _showNotFoundError(DateTime time) {
    final label = DateFormat('hh:mm a').format(time);
    Get.snackbar(
      'Could not open clock app',
      'Please set your alarm manually for $label.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      backgroundColor: const Color(0xFF1A2235),
      colorText: Colors.white,
      icon: const Icon(Icons.alarm_outlined, color: Color(0xFFEF4444)),
    );
  }

  void _showIOSNote(DateTime time) {
    final label = DateFormat('hh:mm a').format(time);
    Get.snackbar(
      'Set alarm for $label',
      'Open your Clock app → Alarm tab → tap + and enter this time.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      backgroundColor: const Color(0xFF1A2235),
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF818CF8)),
    );
  }
}
