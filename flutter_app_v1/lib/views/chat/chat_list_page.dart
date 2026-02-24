import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../utils/helpers.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ChatController>();
    _ctrl.loadConversations();
    _ctrl.fetchUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: RefreshIndicator(
        onRefresh: () async {
          await _ctrl.loadConversations();
          await _ctrl.fetchUnreadCount();
        },
        child: Obx(() {
          if (_ctrl.isLoading.value && _ctrl.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_ctrl.conversations.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              title: 'No Conversations',
              subtitle: 'Start a conversation from a case or lawyer profile',
            );
          }
          final sorted = _ctrl.sortedConversations;
          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final conv = sorted[i];
              final isMe = conv.participantOneId == auth.userId;
              final otherName = conv.otherParticipantName ?? 'User';
              final otherImg = conv.otherParticipantProfilePicture;

              return ListTile(
                leading: ProfileAvatar(
                  name: otherName.isNotEmpty ? otherName : 'U',
                  imageUrl: otherImg,
                  radius: 24,
                ),
                title: Text(
                  otherName.isNotEmpty ? otherName : 'User',
                  style: TextStyle(
                    fontWeight: (conv.unreadCount ?? 0) > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  conv.lastMessage ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Helpers.formatRelativeTime(
                        conv.lastMessageTime ?? conv.createdAt ?? '',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if ((conv.unreadCount ?? 0) > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${conv.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () => Get.toNamed(
                  '/chat/${conv.id}',
                  arguments: {
                    'conversationId': conv.id,
                    'otherName': otherName,
                    'otherImage': otherImg,
                    'otherUserId': isMe
                        ? conv.participantTwoId
                        : conv.participantOneId,
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
