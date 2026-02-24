import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  int _step = 0; // 0=email, 1=code+password

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Get.find<AuthController>();
    final ok = await auth.sendVerificationCode(_emailCtrl.text.trim());
    if (ok) {
      setState(() => _step = 1);
      Get.snackbar(
        'Code Sent',
        'Check your email for the verification code',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        auth.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Get.find<AuthController>();
    final ok = await auth.resetPassword(
      _emailCtrl.text.trim(),
      _codeCtrl.text.trim(),
      _newPwCtrl.text,
    );
    if (ok) {
      Get.snackbar(
        'Success',
        'Password reset successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } else {
      Get.snackbar(
        'Error',
        auth.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_reset, size: 48),
                const SizedBox(height: 16),
                Text(
                  _step == 0 ? 'Enter your email' : 'Enter code & new password',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                  enabled: _step == 0,
                ),
                if (_step == 1) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      prefixIcon: Icon(Icons.pin),
                    ),
                    validator: Validators.otpCode,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPwCtrl,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: Validators.password,
                  ),
                ],
                const SizedBox(height: 24),
                Obx(
                  () => SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.isLoading.value
                          ? null
                          : (_step == 0 ? _sendCode : _resetPassword),
                      child: auth.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_step == 0 ? 'Send Code' : 'Reset Password'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
