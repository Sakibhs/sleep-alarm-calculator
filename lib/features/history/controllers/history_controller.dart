import 'package:get/get.dart';
import '../../../data/models/calculation_history_model.dart';
import '../../../data/services/history_service.dart';

class HistoryController extends GetxController {
  final HistoryService _historyService;

  HistoryController({required HistoryService historyService})
      : _historyService = historyService;

  final entries = <CalculationHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    entries.assignAll(_historyService.getAll());
  }

  Future<void> clearHistory() async {
    await _historyService.clear();
    entries.clear();
  }
}
