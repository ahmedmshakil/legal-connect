import 'package:get/get.dart';
import '../data/models/blog_model.dart';
import '../data/providers/blog_provider.dart';

class BlogController extends GetxController {
  final BlogProvider _provider = BlogProvider();

  final RxList<BlogModel> blogs = <BlogModel>[].obs;
  final Rx<BlogModel?> currentBlog = Rx<BlogModel?>(null);
  final RxList<BlogModel> subscribedBlogs = <BlogModel>[].obs;
  final RxList<BlogModel> searchResults = <BlogModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  Future<void> loadMyBlogs(String authorId) async {
    try {
      isLoading.value = true;
      final response = await _provider.getAuthorBlogs(authorId);
      final data = response.data;
      final listData = data['data'] ?? data;

      if (listData is List) {
        blogs.value = listData.map((e) => BlogModel.fromJson(e)).toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBlog(String blogId) async {
    try {
      isLoading.value = true;
      final response = await _provider.getBlog(blogId);
      final data = response.data;
      final blogData = data['data'] ?? data;

      if (blogData != null && blogData is Map<String, dynamic>) {
        currentBlog.value = BlogModel.fromJson(blogData);
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createBlog(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      await _provider.createBlog(data);
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateBlog(String blogId, Map<String, dynamic> data) async {
    try {
      await _provider.updateBlog(blogId, data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteBlog(String blogId) async {
    try {
      await _provider.deleteBlog(blogId);
      blogs.removeWhere((b) => b.id == blogId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> changeBlogStatus(String blogId, String status) async {
    try {
      await _provider.changeBlogStatus(blogId, {'status': status});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadSubscribedBlogs() async {
    try {
      isLoading.value = true;
      final response = await _provider.getSubscribedBlogs();
      final data = response.data;
      final listData = data['data'] ?? data;

      if (listData is List) {
        subscribedBlogs.value = listData
            .map((e) => BlogModel.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchPublished(String query) async {
    try {
      isLoading.value = true;
      searchQuery.value = query;
      final response = await _provider.searchPublished(query);
      final data = response.data;
      final listData = data['data'] ?? data;

      if (listData is List) {
        searchResults.value = listData
            .map((e) => BlogModel.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> subscribe(String authorId) async {
    try {
      await _provider.subscribe(authorId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unsubscribe(String authorId) async {
    try {
      await _provider.unsubscribe(authorId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
