import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_session_model.dart';
import '../data/providers/ai_chat_provider.dart';
import '../controllers/auth_controller.dart';

class AiChatController extends GetxController {
  final AiChatProvider _provider = AiChatProvider();

  final RxList<ChatSessionModel> sessions = <ChatSessionModel>[].obs;
  final RxList<AiMessageModel> currentMessages = <AiMessageModel>[].obs;
  final Rx<ChatSessionModel?> currentSession = Rx<ChatSessionModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString currentSessionId = ''.obs;
  final RxString error = ''.obs;

  Future<void> loadSessions() async {
    try {
      isLoading.value = true;
      final auth = Get.find<AuthController>();
      final response = await _provider.getUserSessions(auth.userId);
      final data = response.data;

      List<dynamic> sessionsList;
      if (data is List) {
        sessionsList = data;
      } else if (data['data'] != null && data['data'] is List) {
        sessionsList = data['data'];
      } else if (data['sessions'] != null) {
        sessionsList = data['sessions'];
      } else {
        sessionsList = [];
      }

      sessions.value = sessionsList
          .map((e) => ChatSessionModel.fromJson(e))
          .toList();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> createNewSession() async {
    try {
      final sessionId = const Uuid().v4();
      final response = await _provider.createSession(title: 'New Chat');
      final data = response.data;
      final sessData = data['data'] ?? data;

      final newId =
          sessData['id']?.toString() ??
          sessData['session_id']?.toString() ??
          sessionId;

      currentSessionId.value = newId;
      currentMessages.clear();
      await loadSessions();
      return newId;
    } catch (_) {
      final sessionId = const Uuid().v4();
      currentSessionId.value = sessionId;
      currentMessages.clear();
      return sessionId;
    }
  }

  Future<void> loadSession(String sessionId) async {
    try {
      isLoading.value = true;
      currentSessionId.value = sessionId;

      final response = await _provider.getChatHistory(sessionId);
      final data = response.data;

      List<dynamic> msgList;
      if (data is List) {
        msgList = data;
      } else if (data['data'] != null && data['data'] is List) {
        msgList = data['data'];
      } else if (data['messages'] != null) {
        msgList = data['messages'];
      } else if (data['history'] != null) {
        msgList = data['history'];
      } else {
        msgList = [];
      }

      currentMessages.value = msgList
          .map((e) => AiMessageModel.fromJson(e))
          .toList();
    } catch (_) {
      currentMessages.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      isSending.value = true;

      // Add user message immediately
      currentMessages.add(
        AiMessageModel(
          role: 'user',
          content: message,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      // Ensure we have a session
      if (currentSessionId.value.isEmpty) {
        await createNewSession();
      }

      final response = await _provider.sendMessage(
        message: message,
        sessionId: currentSessionId.value,
      );

      final data = response.data;
      final respData = data['data'] ?? data;

      // Add AI response
      final aiMessage = AiMessageModel(
        role: 'assistant',
        content:
            respData['answer'] ??
            respData['response'] ??
            respData['content'] ??
            '',
        sources: respData['sources'] != null
            ? (respData['sources'] as List)
                  .map((s) => SourceDocument.fromJson(s))
                  .toList()
            : null,
        createdAt: DateTime.now().toIso8601String(),
      );
      currentMessages.add(aiMessage);

      // Update session ID if returned
      final newSessionId = respData['session_id']?.toString();
      if (newSessionId != null && newSessionId.isNotEmpty) {
        currentSessionId.value = newSessionId;
      }
    } catch (e) {
      currentMessages.add(
        AiMessageModel(
          role: 'assistant',
          content: 'Sorry, I encountered an error. Please try again.',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<bool> deleteSession(String sessionId) async {
    try {
      await _provider.deleteSession(sessionId);
      sessions.removeWhere((s) => s.id == sessionId);
      if (currentSessionId.value == sessionId) {
        currentSessionId.value = '';
        currentMessages.clear();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> uploadDocument(String sessionId, String filePath) async {
    try {
      isLoading.value = true;
      await _provider.uploadDocument(sessionId, filePath);
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> searchDocuments(String query) async {
    try {
      final response = await _provider.searchDocuments(query: query);
      final data = response.data;
      final results = data['data'] ?? data['results'] ?? data;
      if (results is List) return results;
      return [];
    } catch (_) {
      return [];
    }
  }
}
