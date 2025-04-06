import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferences _prefs;
  final UserService _userService;

  AuthService(this._prefs) : _userService = UserService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create or update user in Firestore
  Future<void> _createOrUpdateUser(User user, {String? displayName}) async {
    print('Creating/updating user in Firestore: ${user.uid}');

    final userModel = UserModel(
      id: user.uid,
      email: user.email,
      displayName: displayName ?? user.displayName,
      photoURL: user.photoURL,
      bio: 'CTIS Dictionary User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('User model created: ${userModel.toMap()}');

    try {
      // First try to get the user to check if they exist
      final existingUser = await _userService.getUser(user.uid);
      if (existingUser != null) {
        print('Updating existing user');
        await _userService.updateUser(userModel);
      } else {
        print('Creating new user');
        await _userService.createUser(userModel);
      }
      print('User successfully created/updated in Firestore');
    } catch (e) {
      print('Error creating/updating user in Firestore: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      print('Signing in with email: $email');
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _prefs.setBool('isLoggedIn', true);
      print('Successfully signed in: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      print('Registering new user: $email');
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created in Firebase Auth: ${userCredential.user?.uid}');

      // Update user profile with display name
      await userCredential.user?.updateDisplayName(displayName);
      print('Updated user display name');

      // Create user in Firestore
      await _createOrUpdateUser(userCredential.user!, displayName: displayName);

      await _prefs.setBool('isLoggedIn', true);
      print('Registration completed successfully');
      return userCredential;
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      print('Starting Google sign in');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');
      print('Google user obtained: ${googleUser.email}');

      // Get the user's Google profile data
      final googleAuth = await googleUser.authentication;
      print('Google authentication successful');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Google credential created: $credential');

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print('Firebase authentication successful: ${userCredential}');

      // Update Firebase user profile with Google data
      if (userCredential.user != null) {
        await userCredential.user?.updateDisplayName(googleUser.displayName);
        await userCredential.user?.updatePhotoURL(googleUser.photoUrl);
        print('Updated Firebase user profile with Google data');
      }

      // Create or update user in Firestore with Google data
      await _createOrUpdateUser(
        userCredential.user!,
        displayName: googleUser.displayName,
      );

      await _prefs.setBool('isLoggedIn', true);
      print('Google sign in completed successfully');
      return userCredential;
    } catch (e) {
      print('Error during Google sign in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out');
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _prefs.setBool('isLoggedIn', false);
      print('Sign out completed');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool('isLoggedIn') ?? false;
  }
}
