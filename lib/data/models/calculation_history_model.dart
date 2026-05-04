import 'package:hive/hive.dart';
import '../../core/utils/time_utils.dart';

part 'calculation_history_model.g.dart';

@HiveType(typeId: 0)
class CalculationHistoryModel extends HiveObject {
  @HiveField(0)
  final String mode; // 'wakeUp' | 'sleepAt'

  @HiveField(1)
  final int inputHour;

  @HiveField(2)
  final int inputMinute;

  @HiveField(3)
  final DateTime calculatedAt;

  @HiveField(4)
  final List<String> resultTimes; // formatted strings stored for display

  CalculationHistoryModel({
    required this.mode,
    required this.inputHour,
    required this.inputMinute,
    required this.calculatedAt,
    required this.resultTimes,
  });

  String get formattedInput {
    final dt = DateTime(
      calculatedAt.year,
      calculatedAt.month,
      calculatedAt.day,
      inputHour,
      inputMinute,
    );
    return TimeUtils.formatTime(dt);
  }

  String get modeLabel => mode == 'wakeUp' ? 'Wake up at' : 'Sleep at';
}
