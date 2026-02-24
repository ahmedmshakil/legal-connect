import 'package:get/get.dart';
import '../data/models/case_model.dart';
import '../data/providers/case_provider.dart';

class CaseController extends GetxController {
  final CaseProvider _provider = CaseProvider();

  final RxList<CaseModel> cases = <CaseModel>[].obs;
  final Rx<CaseModel?> currentCase = Rx<CaseModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalElements = 0.obs;
  final RxString statusFilter = ''.obs;

  List<CaseModel> get inProgressCases =>
      cases.where((c) => c.isInProgress).toList();
  List<CaseModel> get resolvedCases =>
      cases.where((c) => c.isResolved).toList();
  bool get hasMorePages => currentPage.value < totalPages.value - 1;

  Future<void> getAllUserCases({
    int? page,
    String? status,
    bool reset = false,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (reset) {
        currentPage.value = 0;
        cases.clear();
      }

      final response = await _provider.getAllUserCases(
        page: page ?? currentPage.value,
        status:
            status ??
            (statusFilter.value.isNotEmpty ? statusFilter.value : null),
      );

      final data = response.data;
      final pageData = data['data'] ?? data;

      if (pageData != null) {
        final content =
            (pageData['content'] as List?)
                ?.map((e) => CaseModel.fromJson(e))
                .toList() ??
            [];

        if (reset || page == 0) {
          cases.value = content;
        } else {
          cases.addAll(content);
        }

        totalPages.value = pageData['totalPages'] ?? 0;
        totalElements.value = pageData['totalElements'] ?? 0;
        currentPage.value = pageData['number'] ?? 0;
      }
    } catch (e) {
      error.value = 'Failed to load cases';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCaseById(String caseId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _provider.getCaseById(caseId);
      final data = response.data;
      final caseData = data['data'] ?? data;

      if (caseData != null) {
        currentCase.value = CaseModel.fromJson(caseData);
      }
    } catch (e) {
      error.value = 'Failed to load case';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createCase(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _provider.createCase(data);
      await getAllUserCases(reset: true);
      return true;
    } catch (e) {
      error.value = 'Failed to create case';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCase(String caseId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _provider.updateCase(caseId, data);
      await getCaseById(caseId);
      return true;
    } catch (e) {
      error.value = 'Failed to update case';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCaseStatus(
    String caseId,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _provider.updateCaseStatus(caseId, data);
      await getCaseById(caseId);
      return true;
    } catch (e) {
      error.value = 'Failed to update case status';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void setStatusFilter(String status) {
    statusFilter.value = status;
    getAllUserCases(reset: true, status: status.isNotEmpty ? status : null);
  }

  void loadNextPage() {
    if (hasMorePages) {
      currentPage.value++;
      getAllUserCases(page: currentPage.value);
    }
  }
}
