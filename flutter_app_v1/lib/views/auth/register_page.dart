import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';
import '../../app/theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  String _role = 'USER';
  bool _obscure = true;
  bool _obscureConfirm = true;

  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    final begin = (index * 0.1).clamp(0.0, 0.8);
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animCtrl,
        curve: Interval(begin, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animCtrl,
          curve: Interval(begin, 1.0, curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Get.find<AuthController>();
    final success = await auth.register(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _role,
    );
    if (success) {
      Get.snackbar(
        'Success',
        'Account created! Please verify your email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
        margin: const EdgeInsets.all(16),
      );
      Get.toNamed(AppRoutes.verifyEmail, arguments: _emailCtrl.text.trim());
    } else {
      Get.snackbar(
        'Registration Failed',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _staggered(
                  0,
                  Text(
                    'Join Legal Connect',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                _staggered(
                  0,
                  Text(
                    'Create your account to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                // Role selector
                _staggered(
                  1,
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'USER',
                        label: Text('Client'),
                        icon: Icon(Icons.person_rounded),
                      ),
                      ButtonSegment(
                        value: 'LAWYER',
                        label: Text('Lawyer'),
                        icon: Icon(Icons.gavel_rounded),
                      ),
                    ],
                    selected: {_role},
                    onSelectionChanged: (s) =>
                        setState(() => _role = s.first),
                  ),
                ),
                const SizedBox(height: 20),
                // Form card
                _staggered(
                  2,
                  Container(
                    padding: const EdgeInsets.all(20),
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
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: Validators.name,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: Validators.name,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordCtrl,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          obscureText: _obscure,
                          validator: Validators.password,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmPwCtrl,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          obscureText: _obscureConfirm,
                          validator: (v) =>
                              Validators.confirmPassword(v, _passwordCtrl.text),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  auth.isLoading.value ? null : _register,
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
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
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
                ),
                const SizedBox(height: 24),
                _staggered(
                  3,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
