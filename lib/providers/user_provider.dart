import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;

  UserProvider() {
    // Initialize with a default user
    _currentUser = UserModel(
      id: '1',
      displayName: 'User Name',
      email: 'user@example.com',
      bio: 'Welcome to CTIS Dictionary!',
    );
  }

  UserModel? get currentUser => _currentUser;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUser({
    String? displayName,
    String? email,
    String? photoURL,
    String? bio,
  }) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        displayName: displayName ?? _currentUser!.displayName,
        email: email ?? _currentUser!.email,
        photoURL: photoURL ?? _currentUser!.photoURL,
        bio: bio ?? _currentUser!.bio,
      );
      notifyListeners();
    }
  }
}
