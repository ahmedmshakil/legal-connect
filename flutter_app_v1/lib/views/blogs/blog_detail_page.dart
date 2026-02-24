import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../controllers/blog_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/profile_avatar.dart';
import '../../utils/helpers.dart';

class BlogDetailPage extends StatefulWidget {
  const BlogDetailPage({super.key});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  late BlogController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(BlogController());
    final id = Get.parameters['id'] ?? '';
    if (id.isNotEmpty) {
      _ctrl.loadBlog(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        actions: [
          Obx(() {
            final blog = _ctrl.currentBlog.value;
            if (blog == null) return const SizedBox.shrink();
            final isAuthor = blog.authorId == auth.userId;
            if (!isAuthor) return const SizedBox.shrink();
            return PopupMenuButton(
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (blog.isDraft)
                  const PopupMenuItem(value: 'publish', child: Text('Publish')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (v) async {
                if (v == 'edit') Get.toNamed('/blogs/edit/${blog.id}');
                if (v == 'publish') {
                  await _ctrl.changeBlogStatus(blog.id ?? '', 'PUBLISHED');
                  _ctrl.loadBlog(blog.id ?? '');
                }
                if (v == 'delete') {
                  final ok = await _ctrl.deleteBlog(blog.id ?? '');
                  if (ok) Get.back();
                }
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) return const LoadingWidget();
        final blog = _ctrl.currentBlog.value;
        if (blog == null) return const Center(child: Text('Blog not found'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.title ?? '',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ProfileAvatar(name: blog.authorFullName, radius: 16),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.authorFullName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        Helpers.formatDate(blog.createdAt ?? ''),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (blog.authorId != auth.userId)
                    TextButton.icon(
                      onPressed: () => _ctrl.subscribe(blog.authorId ?? ''),
                      icon: const Icon(Icons.bookmark_add, size: 18),
                      label: const Text('Subscribe'),
                    ),
                ],
              ),
              const Divider(height: 32),
              MarkdownBody(
                data: blog.content ?? '',
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
