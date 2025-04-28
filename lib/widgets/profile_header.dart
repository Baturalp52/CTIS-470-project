import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import '../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel userData;

  const ProfileHeader({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 80,
      backgroundColor: Theme.of(context).colorScheme.primary,
      backgroundImage:
          userData.photoURL != null ? NetworkImage(userData.photoURL!) : null,
      child: userData.photoURL == null
          ? Icon(
              Icons.person,
              size: 80,
              color: Colors.white,
            )
          : null,
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          userData.photoURL != null
              ? InstaImageViewer(
                  imageUrl: userData.photoURL!,
                  child: avatar,
                )
              : avatar,
          const SizedBox(height: 16),
          Text(
            userData.displayName ?? 'Anonymous',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userData.email ?? '',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userData.bio ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
