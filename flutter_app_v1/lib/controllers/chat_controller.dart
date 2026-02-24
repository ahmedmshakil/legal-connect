import 'dart:convert';
import 'package:get/get.dart';
import '../data/models/conversation_model.dart';
import '../data/providers/chat_provider.dart';
import '../data/services/chat_websocket_service.dart';
import '../controllers/auth_controller.dart';

class ChatController extends GetxController {
  final ChatProvider _provider = ChatProvider();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final Rx<ConversationModel?> currentConversation = Rx<ConversationModel?>(
    null,
  );
  final RxMap<String, List<MessageModel>> messages =
      <String, List<MessageModel>>{}.obs;
  final RxInt totalUnreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString error = ''.obs;

  List<ConversationModel> get sortedConversations {
    final list = conversations.toList();
    list.sort((a, b) {
      final aTime = a.lastMessageTime ?? a.createdAt ?? '';
      final bTime = b.lastMessageTime ?? b.createdAt ?? '';
      return bTime.compareTo(aTime);
    });
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    try {
      final auth = Get.find<AuthController>();
      final chatWs = Get.find<ChatWebSocketService>();

      ever(chatWs.isConnected, (bool connected) {
        if (connected && auth.userId.isNotEmpty) {
          chatWs.subscribeToMessages(auth.userId, _onMessageReceived);
          chatWs.subscribeToReadStatus(auth.userId, _onReadStatus);
        }
      });
    } catch (_) {}
  }

  void _onMessageReceived(dynamic frame) {
    try {
      final data = jsonDecode(frame.body ?? '{}');
      final msg = MessageModel.fromJson(data);
      final convId = msg.conversationId;
      if (convId == null) return;

      // Add message to conversation
      if (messages.containsKey(convId)) {
        messages[convId]!.add(msg);
        messages.refresh();
      }

      // Update conversation
      loadConversations();
      fetchUnreadCount();
    } catch (_) {}
  }

  void _onReadStatus(dynamic frame) {
    try {
      loadConversations();
    } catch (_) {}
  }

  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      final response = await _provider.getConversations();
      final data = response.data;
      final convData = data['data'] ?? data;

      if (convData != null && convData is List) {
        conversations.value = convData
            .map((e) => ConversationModel.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(String conversationId, {int page = 0}) async {
    try {
      isLoadingMessages.value = true;
      final response = await _provider.getConversationMessages(
        conversationId,
        page: page,
      );
      final data = response.data;
      final pageData = data['data'] ?? data;

      if (pageData != null) {
        final content =
            (pageData['content'] as List?)
                ?.map((e) => MessageModel.fromJson(e))
                .toList() ??
            [];

        if (page == 0) {
          messages[conversationId] = content.reversed.toList();
        } else {
          final existing = messages[conversationId] ?? [];
          messages[conversationId] = [...content.reversed, ...existing];
        }
        messages.refresh();
      }
    } catch (_) {
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<bool> sendMessage(String receiverId, String content) async {
    try {
      await _provider.sendMessage({
        'receiverId': receiverId,
        'content': content,
      });
      await loadConversations();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _provider.markConversationAsRead(conversationId);
      await fetchUnreadCount();
    } catch (_) {}
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _provider.getUnreadCount();
      final data = response.data;
      totalUnreadCount.value = data['data'] ?? data ?? 0;
    } catch (_) {}
  }
}
