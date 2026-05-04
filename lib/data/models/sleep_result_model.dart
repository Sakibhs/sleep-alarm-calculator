import '../../core/constants/app_strings.dart';
import '../../core/utils/time_utils.dart';

enum CycleQuality { veryShort, minimum, good, ideal, best }

class SleepResultModel {
  final DateTime time;
  final int cycleCount;
  final int totalSleepMinutes;

  const SleepResultModel({
    required this.time,
    required this.cycleCount,
    required this.totalSleepMinutes,
  });

  String get formattedTime => TimeUtils.formatTime(time);
  String get formattedDuration => TimeUtils.formatDuration(totalSleepMinutes);

  CycleQuality get quality {
    if (cycleCount >= 6) return CycleQuality.best;
    if (cycleCount == 5) return CycleQuality.ideal;
    if (cycleCount == 4) return CycleQuality.good;
    if (cycleCount == 3) return CycleQuality.minimum;
    return CycleQuality.veryShort;
  }

  bool get isHighlighted => cycleCount == 5 || cycleCount == 6;

  String get insightLabel {
    switch (quality) {
      case CycleQuality.best:
        return AppStrings.insightBestPerformance;
      case CycleQuality.ideal:
        return AppStrings.insightIdeal;
      case CycleQuality.good:
        return AppStrings.insightGood;
      case CycleQuality.minimum:
        return AppStrings.insightMinimum;
      case CycleQuality.veryShort:
        return AppStrings.insightVeryShort;
    }
  }
}
