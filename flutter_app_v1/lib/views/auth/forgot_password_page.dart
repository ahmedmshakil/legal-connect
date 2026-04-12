import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/validators.dart';
import '../../app/theme/app_colors.dart';

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
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'Error',
        auth.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        margin: const EdgeInsets.all(16),
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
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
        margin: const EdgeInsets.all(16),
      );
      Get.back();
    } else {
      Get.snackbar(
        'Error',
        auth.error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _step == 0
                          ? Icons.lock_reset_rounded
                          : Icons.vpn_key_rounded,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _step == 0
                        ? 'Reset Password'
                        : 'Enter Code & New Password',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _step == 0
                        ? 'Enter your email to receive a verification code'
                        : 'Enter the code sent to ${_emailCtrl.text}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _codeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Verification Code',
                              prefixIcon: Icon(Icons.pin_rounded),
                            ),
                            validator: Validators.otpCode,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, letterSpacing: 6),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
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
                        const SizedBox(height: 20),
                        Obx(
                          () => SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: auth.isLoading.value
                                  ? null
                                  : (_step == 0 ? _sendCode : _resetPassword),
                              child: auth.isLoading.value
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _step == 0
                                          ? 'Send Code'
                                          : 'Reset Password',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_step == 1)
                    TextButton(
                      onPressed: _sendCode,
                      child: const Text('Resend Code'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
