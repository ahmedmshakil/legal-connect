import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../controllers/ai_chat_controller.dart';
import '../../widgets/empty_state_widget.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late AiChatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(AiChatController());
    _ctrl.loadSessions();

    final sessionId = Get.parameters['id'];
    if (sessionId != null && sessionId.isNotEmpty) {
      _ctrl.loadSession(sessionId);
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    _ctrl.sendMessage(text).then((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Legal Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showSessionHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _ctrl.createNewSession(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_ctrl.currentMessages.isEmpty && !_ctrl.isSending.value) {
                return const EmptyStateWidget(
                  icon: Icons.smart_toy,
                  title: 'AI Legal Assistant',
                  subtitle:
                      'Ask any legal question. I can help with Bangladesh law, case analysis, and document review.',
                );
              }
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount:
                    _ctrl.currentMessages.length +
                    (_ctrl.isSending.value ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _ctrl.currentMessages.length) {
                    return _buildTypingIndicator();
                  }
                  final msg = _ctrl.currentMessages[i];
                  return _buildMessage(context, msg);
                },
              );
            }),
          ),
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
                    controller: _inputCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ask a legal question...',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    maxLines: null,
                  ),
                ),
                Obx(
                  () => IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _ctrl.isSending.value
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _ctrl.isSending.value ? null : _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, dynamic msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: isUser
            ? Text(
                msg.content ?? '',
                style: const TextStyle(color: Colors.white),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: msg.content ?? '',
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                  ),
                  if (msg.sources != null && msg.sources!.isNotEmpty) ...[
                    const Divider(height: 16),
                    Text(
                      'Sources:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ...msg.sources!
                        .take(3)
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '• ${s.title ?? s.source ?? ''}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text('Thinking...', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _showSessionHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Obx(() {
        final sessions = _ctrl.sessions;
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chat History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: sessions.isEmpty
                  ? const Center(child: Text('No previous sessions'))
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (_, i) {
                        final s = sessions[i];
                        return ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(s.title ?? 'Session ${i + 1}'),
                          subtitle: Text(s.createdAt ?? ''),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _ctrl.deleteSession(s.id ?? ''),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _ctrl.loadSession(s.id ?? '');
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
