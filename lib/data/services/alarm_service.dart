import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AlarmService {
  Future<void> setAlarm(DateTime time) async {
    if (Platform.isAndroid) {
      await _setAndroidAlarm(time);
    } else if (Platform.isIOS) {
      _showIOSNote(time);
    }
  }

  Future<void> _setAndroidAlarm(DateTime time) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': time.hour,
          'android.intent.extra.alarm.MINUTES': time.minute,
          // SKIP_UI = true → alarm is set directly without opening the clock app UI
          'android.intent.extra.alarm.SKIP_UI': true,
          'android.intent.extra.alarm.MESSAGE': 'Sleep Cycle Alarm',
          'android.intent.extra.alarm.VIBRATE': true,
        },
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      _showSuccess(time);
    } catch (e) {
      // SKIP_UI failed — fall back to opening the alarm UI so user can save manually
      await _fallbackOpenAlarmUI(time);
    }
  }

  /// Fallback: open the clock app UI with the time pre-filled.
  Future<void> _fallbackOpenAlarmUI(DateTime time) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.SET_ALARM',
        arguments: <String, dynamic>{
          'android.intent.extra.alarm.HOUR': time.hour,
          'android.intent.extra.alarm.MINUTES': time.minute,
          'android.intent.extra.alarm.SKIP_UI': false,
          'android.intent.extra.alarm.MESSAGE': 'Sleep Cycle Alarm',
        },
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (_) {
      _showError();
    }
  }

  void _showSuccess(DateTime time) {
    final label = DateFormat('hh:mm a').format(time);
    Get.snackbar(
      'Alarm set',
      'Alarm set for $label',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFF1A2235),
      colorText: Colors.white,
      icon: const Icon(Icons.alarm_on_rounded, color: Color(0xFF10B981)),
    );
  }

  void _showIOSNote(DateTime time) {
    final label = DateFormat('hh:mm a').format(time);
    Get.snackbar(
      'Set alarm for $label',
      'Open your Clock app and add this alarm manually.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      backgroundColor: const Color(0xFF1A2235),
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF818CF8)),
    );
  }

  void _showError() {
    Get.snackbar(
      'Could not set alarm',
      'Please open your Clock app and set the alarm manually.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF1A2235),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
    );
  }
}
