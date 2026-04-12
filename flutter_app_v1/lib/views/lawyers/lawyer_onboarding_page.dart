import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lawyer_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import 'package:file_picker/file_picker.dart';

class LawyerOnboardingPage extends StatefulWidget {
  const LawyerOnboardingPage({super.key});

  @override
  State<LawyerOnboardingPage> createState() => _LawyerOnboardingPageState();
}

class _LawyerOnboardingPageState extends State<LawyerOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _firmCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _barCertCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _chargeCtrl = TextEditingController();
  String? _court;
  String? _division;
  String? _district;
  final List<String> _selectedSpecs = [];

  @override
  void dispose() {
    _firmCtrl.dispose();
    _bioCtrl.dispose();
    _barCertCtrl.dispose();
    _expCtrl.dispose();
    _chargeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = Get.find<LawyerController>();
    final ok = await ctrl.createLawyerProfile({
      'lawFirmName': _firmCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'barCertificateNumber': _barCertCtrl.text.trim(),
      'experience': int.tryParse(_expCtrl.text) ?? 0,
      'practicingCourt': _court,
      'division': _division,
      'district': _district,
      'specializations': _selectedSpecs,
      'hourlyCharge': double.tryParse(_chargeCtrl.text) ?? 0,
    });
    if (ok) {
      Get.snackbar(
        'Success',
        'Profile created! Awaiting admin approval.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> _uploadCredentials() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final ctrl = Get.find<LawyerController>();
      await ctrl.uploadCredentials(result.files.single.path!);
      Get.snackbar(
        'Uploaded',
        'Credentials uploaded',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(LawyerController());

    return Scaffold(
      appBar: AppBar(title: const Text('Lawyer Profile Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Complete Your Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your professional details',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firmCtrl,
                decoration: const InputDecoration(labelText: 'Law Firm Name'),
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barCertCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bar Certificate Number',
                ),
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Experience (years)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: Validators.required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _chargeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Charge (৳)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Practicing Court',
                ),
                initialValue: _court,
                items: AppConstants.courts
                    .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _court = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Division'),
                initialValue: _division,
                items: AppConstants.divisions
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _division = v;
                  _district = null;
                }),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'District'),
                initialValue: _district,
                items:
                    (_division != null
                            ? AppConstants.districtsByDivision[_division!] ?? []
                            : <String>[])
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                onChanged: (v) => setState(() => _district = v),
              ),
              const SizedBox(height: 16),
              Text(
                'Specializations',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.specializations
                    .map(
                      (s) => FilterChip(
                        label: Text(s),
                        selected: _selectedSpecs.contains(s),
                        onSelected: (sel) {
                          setState(() {
                            sel
                                ? _selectedSpecs.add(s)
                                : _selectedSpecs.remove(s);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _uploadCredentials,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Credentials'),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: Get.find<LawyerController>().isLoading.value
                        ? null
                        : _submit,
                    child: Get.find<LawyerController>().isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Profile'),
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
