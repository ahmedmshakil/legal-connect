import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/conversation_model.dart';
import '../../widgets/profile_avatar.dart';
import '../../utils/helpers.dart';

class ChatConversationPage extends StatefulWidget {
  const ChatConversationPage({super.key});

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late ChatController _chatCtrl;
  late String _conversationId;
  late String _otherName;
  String? _otherImage;
  String? _otherUserId;

  @override
  void initState() {
    super.initState();
    _chatCtrl = Get.find<ChatController>();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _conversationId = args['conversationId'] ?? Get.parameters['id'] ?? '';
    _otherName = args['otherName'] ?? 'User';
    _otherImage = args['otherImage'];
    _otherUserId = args['otherUserId'];

    if (_conversationId.isNotEmpty) {
      _chatCtrl.loadMessages(_conversationId);
      _chatCtrl.markAsRead(_conversationId);
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _otherUserId == null) return;
    _chatCtrl.sendMessage(_otherUserId!, text).then((_) {
      if (_conversationId.isNotEmpty) {
        _chatCtrl.loadMessages(_conversationId);
      }
    });
    _messageCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ProfileAvatar(name: _otherName, imageUrl: _otherImage, radius: 16),
            const SizedBox(width: 12),
            Text(_otherName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final msgs = _chatCtrl.messages[_conversationId] ?? [];
              if (_chatCtrl.isLoadingMessages.value && msgs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (msgs.isEmpty) {
                return const Center(child: Text('No messages yet. Say hello!'));
              }
              return ListView.builder(
                controller: _scrollCtrl,
                reverse: false,
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final msg = msgs[i];
                  final isMe = msg.senderId == auth.userId;
                  return _buildBubble(context, msg, isMe);
                },
              );
            }),
          ),
          // Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context, MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.content ?? '',
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Helpers.formatRelativeTime(msg.createdAt ?? ''),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white70
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead == true ? Icons.done_all : Icons.done,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
