import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/blog_controller.dart';
import '../../utils/validators.dart';

class BlogEditorPage extends StatefulWidget {
  const BlogEditorPage({super.key});

  @override
  State<BlogEditorPage> createState() => _BlogEditorPageState();
}

class _BlogEditorPageState extends State<BlogEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _isEdit = false;
  String? _blogId;

  @override
  void initState() {
    super.initState();
    _blogId = Get.parameters['id'];
    _isEdit = _blogId != null;
    if (_isEdit) {
      final ctrl = Get.find<BlogController>();
      final blog = ctrl.currentBlog.value;
      if (blog != null) {
        _titleCtrl.text = blog.title ?? '';
        _contentCtrl.text = blog.content ?? '';
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save({String status = 'DRAFT'}) async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = Get.find<BlogController>();
    final data = {
      'title': _titleCtrl.text.trim(),
      'content': _contentCtrl.text.trim(),
      'status': status,
    };
    bool ok;
    if (_isEdit) {
      ok = await ctrl.updateBlog(_blogId!, data);
    } else {
      ok = await ctrl.createBlog(data);
    }
    if (ok) {
      Get.snackbar(
        'Success',
        _isEdit ? 'Blog updated' : 'Blog created',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(BlogController());

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Blog' : 'Create Blog'),
        actions: [
          TextButton(
            onPressed: () => _save(status: 'DRAFT'),
            child: const Text('Save Draft'),
          ),
          TextButton(
            onPressed: () => _save(status: 'PUBLISHED'),
            child: const Text('Publish'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.required,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Content (Markdown supported)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                minLines: 15,
                validator: Validators.required,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
