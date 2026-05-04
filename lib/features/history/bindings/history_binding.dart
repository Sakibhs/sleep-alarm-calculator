import 'package:get/get.dart';
import '../../../data/services/history_service.dart';
import '../controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryController>(
      () => HistoryController(historyService: Get.find<HistoryService>()),
    );
  }
}
