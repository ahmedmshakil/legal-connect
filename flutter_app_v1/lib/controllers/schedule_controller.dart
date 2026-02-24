import 'package:get/get.dart';
import '../data/models/schedule_model.dart';
import '../data/providers/schedule_provider.dart';

class ScheduleController extends GetxController {
  final ScheduleProvider _provider = ScheduleProvider();

  final RxList<ScheduleModel> schedules = <ScheduleModel>[].obs;
  final RxList<ScheduleModel> caseSchedules = <ScheduleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> loadAllSchedules() async {
    try {
      isLoading.value = true;
      final response = await _provider.getAllUserSchedules();
      final data = response.data;
      final pageData = data['data'] ?? data;

      if (pageData != null) {
        final content =
            (pageData['content'] as List?)
                ?.map((e) => ScheduleModel.fromJson(e))
                .toList() ??
            [];
        schedules.value = content;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSchedulesForCase(String caseId) async {
    try {
      isLoading.value = true;
      final response = await _provider.getSchedulesForCase(caseId);
      final data = response.data;
      final listData = data['data'] ?? data;

      if (listData is List) {
        caseSchedules.value = listData
            .map((e) => ScheduleModel.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createSchedule(Map<String, dynamic> data) async {
    try {
      await _provider.createSchedule(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateSchedule(
    String scheduleId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _provider.updateSchedule(scheduleId, data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _provider.deleteSchedule(scheduleId);
      caseSchedules.removeWhere((s) => s.id == scheduleId);
      schedules.removeWhere((s) => s.id == scheduleId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
