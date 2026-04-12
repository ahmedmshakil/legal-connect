import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/animated_list_item.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
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
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No Conversations',
              subtitle: 'Start a conversation from a case or lawyer profile',
            );
          }
          final sorted = _ctrl.sortedConversations;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: sorted.length,
            itemBuilder: (_, i) {
              final conv = sorted[i];
              final isMe = conv.participantOneId == auth.userId;
              final otherName = conv.otherParticipantName ?? 'User';
              final otherImg = conv.otherParticipantProfilePicture;
              final hasUnread = (conv.unreadCount ?? 0) > 0;

              return AnimatedListItem(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: hasUnread
                        ? colorScheme.primaryContainer.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            ProfileAvatar(
                              name: otherName.isNotEmpty ? otherName : 'U',
                              imageUrl: otherImg,
                              radius: 24,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          otherName.isNotEmpty
                                              ? otherName
                                              : 'User',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: hasUnread
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Helpers.formatRelativeTime(
                                          conv.lastMessageTime ??
                                              conv.createdAt ??
                                              '',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: hasUnread
                                                  ? colorScheme.primary
                                                  : colorScheme.outline,
                                              fontWeight: hasUnread
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              fontSize: 11,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conv.lastMessage ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: hasUnread
                                                    ? colorScheme.onSurface
                                                    : colorScheme.outline,
                                                fontWeight: hasUnread
                                                    ? FontWeight.w500
                                                    : FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                      if (hasUnread) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${conv.unreadCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
