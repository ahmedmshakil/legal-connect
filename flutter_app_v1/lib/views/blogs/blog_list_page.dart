import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blog_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/empty_state_widget.dart';
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
  final _searchCtrl = TextEditingController();

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
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blogs'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'My Blogs'),
            Tab(text: 'Subscribed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(),
          ),
        ],
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
                padding: const EdgeInsets.all(16),
                itemCount: _ctrl.blogs.length,
                itemBuilder: (_, i) => _buildBlogCard(_ctrl.blogs[i]),
              );
            }),
          ),
          // Subscribed blogs
          RefreshIndicator(
            onRefresh: () async => _ctrl.loadSubscribedBlogs(),
            child: Obx(() {
              if (_ctrl.subscribedBlogs.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.bookmark_border,
                  title: 'No Subscriptions',
                  subtitle: 'Subscribe to lawyers to see their blog posts',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _ctrl.subscribedBlogs.length,
                itemBuilder: (_, i) => _buildBlogCard(_ctrl.subscribedBlogs[i]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.blogCreate),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildBlogCard(dynamic blog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Get.toNamed('/blogs/${blog.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      blog.title ?? 'Untitled',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      blog.status ?? 'DRAFT',
                      style: const TextStyle(fontSize: 10),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (blog.content != null) ...[
                const SizedBox(height: 8),
                Text(
                  Helpers.truncateText(blog.content!, 100),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                Helpers.formatRelativeTime(blog.createdAt ?? ''),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
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
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    ctrl.searchPublished(query);
    return Obx(() {
      if (ctrl.searchResults.isEmpty) {
        return const Center(child: Text('No results'));
      }
      return ListView.builder(
        itemCount: ctrl.searchResults.length,
        itemBuilder: (_, i) {
          final b = ctrl.searchResults[i];
          return ListTile(
            title: Text(b.title ?? ''),
            subtitle: Text(Helpers.truncateText(b.content ?? '', 60)),
            onTap: () {
              close(context, null);
              Get.toNamed('/blogs/${b.id}');
            },
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox();
}
