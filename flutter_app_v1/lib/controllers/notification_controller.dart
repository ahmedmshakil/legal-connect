import 'dart:convert';
import 'package:get/get.dart';
import '../data/models/notification_model.dart';
import '../data/providers/notification_provider.dart';
import '../data/services/websocket_service.dart';
import '../controllers/auth_controller.dart';

class NotificationController extends GetxController {
  final NotificationProvider _provider = NotificationProvider();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxList<NotificationPreferenceModel> preferences =
      <NotificationPreferenceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    try {
      final auth = Get.find<AuthController>();
      final ws = Get.find<WebSocketService>();

      ever(ws.isConnected, (bool connected) {
        if (connected && auth.userId.isNotEmpty) {
          ws.subscribe('/user/${auth.userId}/notifications', _onNotification);
        }
      });
    } catch (_) {}
  }

  void _onNotification(dynamic frame) {
    try {
      final data = jsonDecode(frame.body ?? '{}');
      final notification = NotificationModel.fromJson(data);
      notifications.insert(0, notification);
      unreadCount.value++;
    } catch (_) {}
  }

  Future<void> loadNotifications({int? page, bool reset = false}) async {
    try {
      isLoading.value = true;
      if (reset) {
        currentPage.value = 0;
        notifications.clear();
      }

      final response = await _provider.getNotifications(
        page: page ?? currentPage.value,
      );
      final data = response.data;
      final pageData = data['data'] ?? data;

      if (pageData != null) {
        final content =
            (pageData['content'] as List?)
                ?.map((e) => NotificationModel.fromJson(e))
                .toList() ??
            [];

        if (reset) {
          notifications.value = content;
        } else {
          notifications.addAll(content);
        }

        totalPages.value = pageData['totalPages'] ?? 0;
        currentPage.value = pageData['number'] ?? 0;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _provider.getUnreadCount();
      final data = response.data;
      unreadCount.value = data['data'] ?? data ?? 0;
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _provider.markAsRead(notificationId);
      final idx = notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        notifications[idx] = NotificationModel(
          id: notifications[idx].id,
          receiverId: notifications[idx].receiverId,
          content: notifications[idx].content,
          isRead: true,
          type: notifications[idx].type,
          createdAt: notifications[idx].createdAt,
        );
      }
      await fetchUnreadCount();
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _provider.markAllAsRead();
      notifications.value = notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              receiverId: n.receiverId,
              content: n.content,
              isRead: true,
              type: n.type,
              createdAt: n.createdAt,
            ),
          )
          .toList();
      unreadCount.value = 0;
    } catch (_) {}
  }

  Future<void> loadPreferences() async {
    try {
      final response = await _provider.getPreferences();
      final data = response.data;
      final prefsData = data['data'] ?? data;

      if (prefsData != null && prefsData is List) {
        preferences.value = prefsData
            .map((e) => NotificationPreferenceModel.fromJson(e))
            .toList();
      }
    } catch (_) {}
  }

  Future<bool> updatePreference(String type, Map<String, dynamic> data) async {
    try {
      await _provider.updatePreference(type, data);
      await loadPreferences();
      return true;
    } catch (_) {
      return false;
    }
  }
}
