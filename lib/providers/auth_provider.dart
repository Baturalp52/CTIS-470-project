import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  User? _user;
  UserModel? _userData;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<UserModel?>? _userDataSubscription;

  AuthProvider(this._authService) : _userService = UserService() {
    _authStateSubscription =
        _authService.authStateChanges.listen((User? user) async {
      if (_user?.uid != user?.uid) {
        _user = user;
        if (user != null) {
          // Subscribe to user data changes
          _userDataSubscription?.cancel();
          _userDataSubscription =
              _userService.streamUser(user.uid).listen((userData) {
            _userData = userData;
            notifyListeners();
          });
        } else {
          _userData = null;
          _userDataSubscription?.cancel();
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _userDataSubscription?.cancel();
    super.dispose();
  }

  User? get user => _user;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithGoogle();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
      String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(
          email, password, displayName);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) {
        throw Exception('User not authenticated');
      }

      // Update Firebase Auth profile
      await _user!.updateDisplayName(displayName);
      await _user!.updatePhotoURL(photoURL);

      // Update Firestore user data
      if (_userData != null) {
        _userData!.displayName = displayName;
        _userData!.photoURL = photoURL;
        await _userService.updateUser(_userData!);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
