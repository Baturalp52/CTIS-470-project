import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  UserProvider() {
    // Initialize with a default user
    _currentUser = User(
      id: '1',
      name: 'User Name',
      email: 'user@example.com',
      bio: 'Welcome to CTIS Dictionary!',
    );
  }

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUser({
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
  }) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        bio: bio ?? _currentUser!.bio,
      );
      notifyListeners();
    }
  }
}
