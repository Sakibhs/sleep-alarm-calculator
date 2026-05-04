import 'package:flutter/services.dart';

/// Thin wrapper around HapticFeedback so call-sites stay clean.
class HapticUtils {
  HapticUtils._();

  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
}
