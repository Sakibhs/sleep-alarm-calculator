import 'package:hive_flutter/hive_flutter.dart';
import '../models/calculation_history_model.dart';

class HistoryService {
  static const String _boxName = 'calculation_history';
  static const int _maxEntries = 5;

  Box<CalculationHistoryModel>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<CalculationHistoryModel>(_boxName);
  }

  List<CalculationHistoryModel> getAll() {
    final box = _box;
    if (box == null) return [];
    final items = box.values.toList()
      ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
    return items;
  }

  Future<void> save(CalculationHistoryModel entry) async {
    final box = _box;
    if (box == null) return;

    await box.add(entry);

    // Keep only the most recent [_maxEntries]
    if (box.length > _maxEntries) {
      final sorted = box.values.toList()
        ..sort((a, b) => a.calculatedAt.compareTo(b.calculatedAt));
      for (int i = 0; i < box.length - _maxEntries; i++) {
        await sorted[i].delete();
      }
    }
  }

  Future<void> clear() async => _box?.clear();
}
