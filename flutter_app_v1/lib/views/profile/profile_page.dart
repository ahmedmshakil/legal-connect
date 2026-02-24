import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/confirm_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final theme = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Obx(() {
              final user = auth.userInfo.value;
              return Column(
                children: [
                  Stack(
                    children: [
                      ProfileAvatar(
                        name: user?.fullName ?? 'U',
                        imageUrl: user?.profilePictureUrl,
                        radius: 50,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () => _pickImage(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Chip(label: Text(user?.role ?? '')),
                ],
              );
            }),
            const SizedBox(height: 24),
            // Settings
            Card(
              child: Column(
                children: [
                  _tile(
                    context,
                    Icons.lock,
                    'Change Password',
                    () => Get.toNamed(AppRoutes.changePassword),
                  ),
                  _tile(
                    context,
                    Icons.notifications,
                    'Notification Settings',
                    () => Get.toNamed(AppRoutes.notifications),
                  ),
                  Obx(
                    () => SwitchListTile(
                      secondary: Icon(
                        theme.isDark.value ? Icons.dark_mode : Icons.light_mode,
                      ),
                      title: const Text('Dark Mode'),
                      value: theme.isDark.value,
                      onChanged: (_) => theme.toggleTheme(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  if (auth.isLawyer)
                    _tile(
                      context,
                      Icons.person,
                      'Lawyer Profile',
                      () => Get.toNamed(AppRoutes.lawyerProfile),
                    ),
                  _tile(
                    context,
                    Icons.email,
                    'Verify Email',
                    () => Get.toNamed(AppRoutes.verifyEmail),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Logout',
                    message: 'Are you sure you want to logout?',
                    confirmLabel: 'Logout',
                    isDestructive: true,
                  );
                  if (ok == true) auth.logout();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final image = await picker.pickImage(source: source, maxWidth: 1024);
      if (image != null) {
        Get.find<AuthController>().uploadProfilePicture(image.path);
      }
    }
  }
}
