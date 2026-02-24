import 'package:get/get.dart';
import '../data/models/lawyer_model.dart';
import '../data/models/availability_slot_model.dart';
import '../data/providers/lawyer_provider.dart';

class LawyerController extends GetxController {
  final LawyerProvider _provider = LawyerProvider();

  final Rx<LawyerModel?> lawyerInfo = Rx<LawyerModel?>(null);
  final RxList<AvailabilitySlotModel> availabilitySlots =
      <AvailabilitySlotModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get hasProfile => lawyerInfo.value != null;
  bool get isVerified => lawyerInfo.value?.isApproved ?? false;
  bool get isPending => lawyerInfo.value?.isPending ?? false;
  bool get isRejected => lawyerInfo.value?.isRejected ?? false;
  bool get canAccessDashboard => hasProfile && isVerified;

  Future<void> fetchLawyerInfo({String? email}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _provider.getLawyerInfo(email: email);
      final data = response.data;
      final lawyerData = data['data'] ?? data;

      if (lawyerData != null && lawyerData is Map<String, dynamic>) {
        lawyerInfo.value = LawyerModel.fromJson(lawyerData);
      }
    } catch (e) {
      // No profile is expected for new lawyers
      lawyerInfo.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createLawyerProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _provider.createLawyerProfile(data);
      await fetchLawyerInfo();
      return true;
    } catch (e) {
      error.value = 'Failed to create profile';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLawyerProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _provider.updateLawyerProfile(data);
      await fetchLawyerInfo();
      return true;
    } catch (e) {
      error.value = 'Failed to update profile';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadCredentials(String filePath) async {
    try {
      isLoading.value = true;
      await _provider.uploadCredentials(filePath);
      return true;
    } catch (e) {
      error.value = 'Failed to upload credentials';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAvailabilitySlots({String? email}) async {
    try {
      final response = await _provider.getAvailabilitySlots(email: email);
      final data = response.data;
      final slotsData = data['data'] ?? data;

      if (slotsData != null && slotsData is List) {
        availabilitySlots.value = slotsData
            .map((e) => AvailabilitySlotModel.fromJson(e))
            .toList();
      }
    } catch (_) {}
  }

  Future<bool> createAvailabilitySlot(Map<String, dynamic> data) async {
    try {
      await _provider.createAvailabilitySlot(data);
      await fetchAvailabilitySlots();
      return true;
    } catch (e) {
      error.value = 'Failed to create slot';
      return false;
    }
  }

  Future<bool> updateAvailabilitySlot(
    String slotId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _provider.updateAvailabilitySlot(slotId, data);
      await fetchAvailabilitySlots();
      return true;
    } catch (e) {
      error.value = 'Failed to update slot';
      return false;
    }
  }

  Future<bool> deleteAvailabilitySlot(String slotId) async {
    try {
      await _provider.deleteAvailabilitySlot(slotId);
      await fetchAvailabilitySlots();
      return true;
    } catch (e) {
      error.value = 'Failed to delete slot';
      return false;
    }
  }

  Future<bool> updateHourlyCharge(double charge) async {
    try {
      await _provider.updateHourlyCharge(charge);
      await fetchLawyerInfo();
      return true;
    } catch (_) {
      return false;
    }
  }
}
