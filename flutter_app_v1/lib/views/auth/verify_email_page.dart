import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final _codeCtrl = TextEditingController();
  late String _email;

  @override
  void initState() {
    super.initState();
    _email = Get.arguments as String? ?? Get.find<AuthController>().userEmail;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    final auth = Get.find<AuthController>();
    final ok = await auth.verifyEmail(_email, _codeCtrl.text.trim());
    if (ok) {
      Get.snackbar(
        'Success',
        'Email verified successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (auth.isLawyer) {
        Get.offAllNamed(AppRoutes.lawyerDashboard);
      } else {
        Get.offAllNamed(AppRoutes.userDashboard);
      }
    } else {
      Get.snackbar(
        'Error',
        auth.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  Future<void> _resend() async {
    final auth = Get.find<AuthController>();
    final ok = await auth.sendVerificationCode(_email);
    if (ok) {
      Get.snackbar(
        'Code Sent',
        'Check your email',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_read, size: 64),
              const SizedBox(height: 16),
              Text(
                'Verify your email',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the code sent to $_email',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  prefixIcon: Icon(Icons.pin),
                ),
                validator: Validators.otpCode,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: auth.isLoading.value ? null : _verify,
                    child: auth.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: _resend, child: const Text('Resend Code')),
            ],
          ),
        ),
      ),
    );
  }
}
