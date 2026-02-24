import 'package:dio/dio.dart';
import 'api_provider.dart';

class BlogProvider {
  final Dio _dio = ApiProvider().dio;

  Future<Response> createBlog(Map<String, dynamic> data) {
    return _dio.post('/blogs', data: data);
  }

  Future<Response> updateBlog(String blogId, Map<String, dynamic> data) {
    return _dio.put('/blogs/$blogId', data: data);
  }

  Future<Response> deleteBlog(String blogId) {
    return _dio.delete('/blogs/$blogId');
  }

  Future<Response> changeBlogStatus(String blogId, Map<String, dynamic> data) {
    return _dio.put('/blogs/$blogId/status', data: data);
  }

  Future<Response> getBlog(String blogId) {
    return _dio.get('/blogs/$blogId');
  }

  Future<Response> getAuthorBlogs(String authorId) {
    return _dio.get('/blogs/authors/$authorId');
  }

  Future<Response> subscribe(String authorId) {
    return _dio.post('/blogs/authors/$authorId/subscribe');
  }

  Future<Response> unsubscribe(String authorId) {
    return _dio.delete('/blogs/authors/$authorId/subscribe');
  }

  Future<Response> getSubscribers() {
    return _dio.get('/blogs/authors/subscribers');
  }

  Future<Response> getSubscribedBlogs() {
    return _dio.get('/blogs/subscribed');
  }

  Future<Response> searchPublished(String query) {
    return _dio.get('/blogs/search', queryParameters: {'q': query});
  }
}
