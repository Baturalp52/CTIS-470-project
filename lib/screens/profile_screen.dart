import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'user_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('User not found'),
            ),
          );
        }

        return UserProfileScreen(
          user: user,
          isCurrentUser: true,
        );
      },
    );
  }
}
