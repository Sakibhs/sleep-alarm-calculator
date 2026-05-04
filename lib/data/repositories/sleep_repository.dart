import '../models/sleep_result_model.dart';
import '../../core/utils/time_utils.dart';

class SleepRepository {
  /// Calculates optimal bedtimes given a target [wakeUpTime].
  /// Returns cycles from [minCycles] down to [maxCycles] (largest first).
  List<SleepResultModel> calculateBedTimes({
    required DateTime wakeUpTime,
    int minCycles = 2,
    int maxCycles = 7,
  }) {
    final results = <SleepResultModel>[];

    for (int cycles = maxCycles; cycles >= minCycles; cycles--) {
      final totalMinutes =
          (cycles * TimeUtils.cycleMinutes) + TimeUtils.fallAsleepMinutes;
      final bedTime = TimeUtils.subtractMinutes(wakeUpTime, totalMinutes);

      results.add(
        SleepResultModel(
          time: bedTime,
          cycleCount: cycles,
          totalSleepMinutes: cycles * TimeUtils.cycleMinutes,
        ),
      );
    }

    return results;
  }

  /// Calculates optimal wake-up times given a [sleepTime].
  /// Returns cycles from [minCycles] up to [maxCycles] (smallest first).
  List<SleepResultModel> calculateWakeUpTimes({
    required DateTime sleepTime,
    int minCycles = 2,
    int maxCycles = 7,
  }) {
    final results = <SleepResultModel>[];

    for (int cycles = minCycles; cycles <= maxCycles; cycles++) {
      final totalMinutes =
          (cycles * TimeUtils.cycleMinutes) + TimeUtils.fallAsleepMinutes;
      final wakeTime = TimeUtils.addMinutes(sleepTime, totalMinutes);

      results.add(
        SleepResultModel(
          time: wakeTime,
          cycleCount: cycles,
          totalSleepMinutes: cycles * TimeUtils.cycleMinutes,
        ),
      );
    }

    return results;
  }
}
