import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Add your web client ID here
    clientId: kIsWeb
        ? '1034228384766-3ual1p1hijsn6umbopr5d3cbqvmnp3r1.apps.googleusercontent.com'
        : null,
  );
  final SharedPreferences _prefs;
  final UserService _userService;

  AuthService(this._prefs) : _userService = UserService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create or update user in Firestore
  Future<void> _createOrUpdateUser(User user, {String? displayName}) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email,
      displayName: displayName ?? user.displayName,
      photoURL: user.photoURL,
      bio: 'CTIS Dictionary User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // First try to get the user to check if they exist
    final existingUser = await _userService.getUser(user.uid);
    if (existingUser == null) {
      // Only create user if they don't exist
      await _userService.createUser(userModel);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _prefs.setBool('isLoggedIn', true);
    return userCredential;
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update user profile with display name
    await userCredential.user?.updateDisplayName(displayName);

    // Create user in Firestore
    await _createOrUpdateUser(userCredential.user!, displayName: displayName);

    await _prefs.setBool('isLoggedIn', true);
    return userCredential;
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in aborted');

    // Get the user's Google profile data
    final googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Update Firebase user profile with Google data
    if (userCredential.user != null) {
      await userCredential.user?.updateDisplayName(googleUser.displayName);
      await userCredential.user?.updatePhotoURL(googleUser.photoUrl);
    }

    // Create or update user in Firestore with Google data
    await _createOrUpdateUser(
      userCredential.user!,
      displayName: googleUser.displayName,
    );

    await _prefs.setBool('isLoggedIn', true);
    return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _prefs.setBool('isLoggedIn', false);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool('isLoggedIn') ?? false;
  }
}
