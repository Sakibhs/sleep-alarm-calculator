import 'package:get/get.dart';
import '../../../data/repositories/sleep_repository.dart';
import '../../../data/services/alarm_service.dart';
import '../../../data/services/history_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        repository: SleepRepository(),
        alarmService: AlarmService(),
        historyService: Get.find<HistoryService>(),
      ),
    );
  }
}
