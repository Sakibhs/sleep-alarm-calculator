import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/models/calculation_history_model.dart';
import '../../../data/models/sleep_result_model.dart';
import '../../../data/repositories/sleep_repository.dart';
import '../../../data/services/alarm_service.dart';
import '../../../data/services/history_service.dart';

enum CalculationMode { wakeUp, sleepAt }

class HomeController extends GetxController {
  final SleepRepository _repository;
  final AlarmService _alarmService;
  final HistoryService _historyService;

  HomeController({
    required SleepRepository repository,
    required AlarmService alarmService,
    required HistoryService historyService,
  })  : _repository = repository,
        _alarmService = alarmService,
        _historyService = historyService;

  // ── Observables ──────────────────────────────────────────────
  final mode = CalculationMode.wakeUp.obs;
  final selectedHour = TimeOfDay.now().hour.obs;
  final selectedMinute = TimeOfDay.now().minute.obs;
  final results = <SleepResultModel>[].obs;
  final isCalculated = false.obs;
  final isLoading = false.obs;

  // ── Getters ──────────────────────────────────────────────────
  bool get isWakeUpMode => mode.value == CalculationMode.wakeUp;

  String get selectedTimeLabel {
    final h = selectedHour.value;
    final m = selectedMinute.value;
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    final displayM = m.toString().padLeft(2, '0');
    return '$displayH:$displayM $period';
  }

  // ── Actions ──────────────────────────────────────────────────
  void toggleMode() {
    HapticUtils.medium();
    mode.value = isWakeUpMode ? CalculationMode.sleepAt : CalculationMode.wakeUp;
    results.clear();
    isCalculated.value = false;
  }

  void updateTime(int hour, int minute) {
    HapticUtils.selection();
    selectedHour.value = hour;
    selectedMinute.value = minute;
    if (isCalculated.value) calculate();
  }

  void calculate() {
    HapticUtils.medium();
    isLoading.value = true;

    final inputTime = TimeUtils.fromTimeOfDay(
      selectedHour.value,
      selectedMinute.value,
      nextDayIfPast: isWakeUpMode,
    );

    final computed = isWakeUpMode
        ? _repository.calculateBedTimes(wakeUpTime: inputTime)
        : _repository.calculateWakeUpTimes(sleepTime: inputTime);

    results.assignAll(computed);
    isCalculated.value = true;
    isLoading.value = false;

    _saveToHistory(inputTime);
  }

  Future<void> setAlarm(DateTime time) async {
    HapticUtils.heavy();
    await _alarmService.setAlarm(time);
  }

  void _saveToHistory(DateTime inputTime) {
    try {
      final entry = CalculationHistoryModel(
        mode: isWakeUpMode ? 'wakeUp' : 'sleepAt',
        inputHour: inputTime.hour,
        inputMinute: inputTime.minute,
        calculatedAt: DateTime.now(),
        resultTimes: results.map((r) => r.formattedTime).toList(),
      );
      _historyService.save(entry);
    } catch (_) {
      // History save failure is non-critical; silently ignore.
    }
  }

  void openTimePicker(BuildContext context) async {
    HapticUtils.light();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: selectedHour.value,
        minute: selectedMinute.value,
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Color(0xFF1A2235),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      updateTime(picked.hour, picked.minute);
    }
  }
}
