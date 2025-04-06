import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class UserService extends FirestoreService {
  static const String collection = 'users';

  Future<String> createUser(UserModel user) async {
    print('Creating user in Firestore: ${user.id}');
    try {
      await firestore.collection(collection).doc(user.id!).set(user.toMap());
      print('User created successfully with ID: ${user.id}');
      return user.id!;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    if (user.id == null) throw Exception('User ID is required for update');
    print('Updating user in Firestore: ${user.id}');
    try {
      await firestore.collection(collection).doc(user.id!).update(user.toMap());
      print('User updated successfully');
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String userId) async {
    print('Getting user from Firestore: $userId');
    try {
      final doc = await firestore.collection(collection).doc(userId).get();
      if (!doc.exists) {
        print('User not found');
        return null;
      }
      print('User found: ${doc.data()}');
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  Stream<UserModel?> streamUser(String userId) {
    print('Streaming user data: $userId');
    return firestore.collection(collection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        print('User document does not exist');
        return null;
      }
      print('User data updated: ${doc.data()}');
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> addFavoriteTopic(String userId, String topicId) async {
    print('Adding favorite topic: $topicId for user: $userId');
    try {
      await firestore.collection(collection).doc(userId).update({
        'favoriteTopics': FieldValue.arrayUnion([topicId])
      });
      print('Favorite topic added successfully');
    } catch (e) {
      print('Error adding favorite topic: $e');
      rethrow;
    }
  }

  Future<void> removeFavoriteTopic(String userId, String topicId) async {
    print('Removing favorite topic: $topicId for user: $userId');
    try {
      await firestore.collection(collection).doc(userId).update({
        'favoriteTopics': FieldValue.arrayRemove([topicId])
      });
      print('Favorite topic removed successfully');
    } catch (e) {
      print('Error removing favorite topic: $e');
      rethrow;
    }
  }

  Future<void> addLikedEntry(String userId, String entryId) async {
    print('Adding liked entry: $entryId for user: $userId');
    try {
      await firestore.collection(collection).doc(userId).update({
        'likedEntries': FieldValue.arrayUnion([entryId])
      });
      print('Liked entry added successfully');
    } catch (e) {
      print('Error adding liked entry: $e');
      rethrow;
    }
  }

  Future<void> removeLikedEntry(String userId, String entryId) async {
    print('Removing liked entry: $entryId for user: $userId');
    try {
      await firestore.collection(collection).doc(userId).update({
        'likedEntries': FieldValue.arrayRemove([entryId])
      });
      print('Liked entry removed successfully');
    } catch (e) {
      print('Error removing liked entry: $e');
      rethrow;
    }
  }

  Future<void> addDislikedEntry(String userId, String entryId) async {
    print('Adding disliked entry: $entryId for user: $userId');
    try {
      await firestore.collection(collection).doc(userId).update({
        'dislikedEntries': FieldValue.arrayUnion([entryId])
      });
      print('Disliked entry added successfully');
    } catch (e) {
      print('Error adding disliked entry: $e');
      rethrow;
    }
  }

  Future<void> removeDislikedEntry(String userId, String entryId) async {
    print('Removing disliked entry: $entryId for user: $userId');
    try {
      await firestore.collection(collection).doc(userId).update({
        'dislikedEntries': FieldValue.arrayRemove([entryId])
      });
      print('Disliked entry removed successfully');
    } catch (e) {
      print('Error removing disliked entry: $e');
      rethrow;
    }
  }
}
