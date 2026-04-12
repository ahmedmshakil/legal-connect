import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blog_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/status_badge.dart';
import '../../routes/app_routes.dart';
import '../../utils/helpers.dart';

class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage>
    with SingleTickerProviderStateMixin {
  late BlogController _ctrl;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(BlogController());
    _tabCtrl = TabController(length: 2, vsync: this);
    final auth = Get.find<AuthController>();
    _ctrl.loadMyBlogs(auth.userId);
    _ctrl.loadSubscribedBlogs();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blogs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearch(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'My Blogs'),
            Tab(text: 'Subscribed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // My blogs
          RefreshIndicator(
            onRefresh: () async => _ctrl.loadMyBlogs(auth.userId),
            child: Obx(() {
              if (_ctrl.isLoading.value && _ctrl.blogs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_ctrl.blogs.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.article_outlined,
                  title: 'No Blogs Yet',
                  subtitle: 'Write your first blog post',
                  actionLabel: 'Create Blog',
                  onAction: () => Get.toNamed(AppRoutes.blogCreate),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                itemCount: _ctrl.blogs.length,
                itemBuilder: (_, i) => AnimatedListItem(
                  index: i,
                  child: _buildBlogCard(_ctrl.blogs[i]),
                ),
              );
            }),
          ),
          // Subscribed blogs
          RefreshIndicator(
            onRefresh: () async => _ctrl.loadSubscribedBlogs(),
            child: Obx(() {
              if (_ctrl.subscribedBlogs.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.bookmark_outline_rounded,
                  title: 'No Subscriptions',
                  subtitle: 'Subscribe to lawyers to see their blog posts',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                itemCount: _ctrl.subscribedBlogs.length,
                itemBuilder: (_, i) => AnimatedListItem(
                  index: i,
                  child: _buildBlogCard(_ctrl.subscribedBlogs[i]),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.blogCreate),
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }

  Widget _buildBlogCard(dynamic blog) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed('/blogs/${blog.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        blog.title ?? 'Untitled',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(label: blog.status ?? 'DRAFT', showDot: false),
                  ],
                ),
                if (blog.content != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    Helpers.truncateText(blog.content!, 120),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.outline, height: 1.5),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 13, color: colorScheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      Helpers.formatRelativeTime(blog.createdAt ?? ''),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch(context: context, delegate: _BlogSearchDelegate(_ctrl));
  }
}

class _BlogSearchDelegate extends SearchDelegate {
  final BlogController ctrl;
  _BlogSearchDelegate(this.ctrl);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
            icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    ctrl.searchPublished(query);
    return Obx(() {
      if (ctrl.searchResults.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No Results',
          subtitle: 'Try a different search term',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.searchResults.length,
        itemBuilder: (_, i) {
          final b = ctrl.searchResults[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                title: Text(b.title ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(Helpers.truncateText(b.content ?? '', 60)),
                onTap: () {
                  close(context, null);
                  Get.toNamed('/blogs/${b.id}');
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox();
}
