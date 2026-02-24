import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/helpers.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = Helpers.getInitials(name);
    final child = imageUrl != null && imageUrl!.isNotEmpty
        ? CircleAvatar(
            radius: radius,
            backgroundImage: CachedNetworkImageProvider(imageUrl!),
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }
}
