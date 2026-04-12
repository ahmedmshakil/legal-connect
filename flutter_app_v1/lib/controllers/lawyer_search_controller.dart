import 'package:get/get.dart';
import '../data/models/lawyer_model.dart';
import '../data/providers/lawyer_directory_provider.dart';

class LawyerSearchController extends GetxController {
  final LawyerDirectoryProvider _provider = LawyerDirectoryProvider();

  final RxList<LawyerModel> lawyers = <LawyerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool searched = false.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;

  // Filters
  final RxnInt minExperience = RxnInt();
  final RxnInt maxExperience = RxnInt();
  final RxString practicingCourt = ''.obs;
  final RxString division = ''.obs;
  final RxString district = ''.obs;
  final RxString specialization = ''.obs;

  Future<void> searchLawyers({bool reset = false}) async {
    try {
      isLoading.value = true;
      searched.value = true;

      if (reset) {
        currentPage.value = 0;
        lawyers.clear();
      }

      final filters = <String, dynamic>{};
      if (minExperience.value != null) {
        filters['minExperience'] = minExperience.value;
      }
      if (maxExperience.value != null) {
        filters['maxExperience'] = maxExperience.value;
      }
      if (practicingCourt.value.isNotEmpty) {
        filters['practicingCourt'] = practicingCourt.value;
      }
      if (division.value.isNotEmpty) filters['division'] = division.value;
      if (district.value.isNotEmpty) filters['district'] = district.value;
      if (specialization.value.isNotEmpty) {
        filters['specialization'] = specialization.value;
      }

      final response = await _provider.findLawyers(
        page: currentPage.value,
        filters: filters,
      );

      final data = response.data;
      final pageData = data['data'] ?? data;
      final metadata = data['metadata'];

      if (pageData != null) {
        // Backend returns List<LawyerSearchResultDTO> directly
        final lawyerList = pageData is List
            ? pageData
            : (pageData['content'] ?? []);
        final content =
            (lawyerList as List?)
                ?.map((e) => LawyerModel.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [];

        if (reset) {
          lawyers.value = content;
        } else {
          lawyers.addAll(content);
        }

        totalPages.value = metadata?['totalPages'] ?? pageData['totalPages'] ?? 0;
        currentPage.value = metadata?['pageNumber'] ?? pageData['number'] ?? 0;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    minExperience.value = null;
    maxExperience.value = null;
    practicingCourt.value = '';
    division.value = '';
    district.value = '';
    specialization.value = '';
    searched.value = false;
    lawyers.clear();
  }
}
