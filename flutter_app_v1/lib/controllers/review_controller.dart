import 'package:get/get.dart';
import '../data/models/review_model.dart';
import '../data/providers/lawyer_directory_provider.dart';

class ReviewController extends GetxController {
  final LawyerDirectoryProvider _provider = LawyerDirectoryProvider();

  final RxMap<String, ReviewModel?> reviewsByCaseId =
      <String, ReviewModel?>{}.obs;
  final RxList<ReviewModel> lawyerReviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchReview(String caseId) async {
    try {
      final response = await _provider.getReviewByCaseId(caseId);
      final data = response.data;
      final reviewData = data['data'] ?? data;

      if (reviewData != null && reviewData is Map<String, dynamic>) {
        reviewsByCaseId[caseId] = ReviewModel.fromJson(reviewData);
      }
    } catch (_) {
      reviewsByCaseId[caseId] = null;
    }
  }

  Future<void> fetchLawyerReviews(String lawyerId) async {
    try {
      isLoading.value = true;
      final response = await _provider.getLawyerReviews(lawyerId);
      final data = response.data;
      final listData = data['data'] ?? data;

      if (listData is List) {
        lawyerReviews.value = listData
            .map((e) => ReviewModel.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addReview(Map<String, dynamic> data) async {
    try {
      await _provider.addReview(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateReview(String reviewId, Map<String, dynamic> data) async {
    try {
      await _provider.updateReview(reviewId, data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _provider.deleteReview(reviewId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
