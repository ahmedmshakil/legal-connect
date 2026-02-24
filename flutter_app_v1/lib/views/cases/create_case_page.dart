import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/case_controller.dart';
import '../../utils/validators.dart';

class CreateCasePage extends StatefulWidget {
  const CreateCasePage({super.key});

  @override
  State<CreateCasePage> createState() => _CreateCasePageState();
}

class _CreateCasePageState extends State<CreateCasePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = Get.find<CaseController>();
    final ok = await ctrl.createCase({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
    });
    if (ok) {
      Get.snackbar(
        'Success',
        'Case created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } else {
      Get.snackbar(
        'Error',
        ctrl.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(CaseController());

    return Scaffold(
      appBar: AppBar(title: const Text('Create Case')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Case Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: Validators.required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: Validators.required,
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: ctrl.isLoading.value ? null : _submit,
                    child: ctrl.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Case'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
