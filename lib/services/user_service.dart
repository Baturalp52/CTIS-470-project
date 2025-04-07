import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class UserService extends FirestoreService {
  static const String collection = 'users';

  Future<String> createUser(UserModel user) async {
    await firestore.collection(collection).doc(user.id!).set(user.toMap());
    return user.id!;
  }

  Future<void> updateUser(UserModel user) async {
    if (user.id == null) throw Exception('User ID is required for update');
    await firestore.collection(collection).doc(user.id!).update(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await firestore.collection(collection).doc(userId).get();
    if (!doc.exists) {
      return null;
    }
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Stream<UserModel?> streamUser(String userId) {
    return firestore.collection(collection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> addFavoriteTopic(String userId, String topicId) async {
    await firestore.collection(collection).doc(userId).update({
      'favoriteTopics': FieldValue.arrayUnion([topicId])
    });
  }

  Future<void> removeFavoriteTopic(String userId, String topicId) async {
    await firestore.collection(collection).doc(userId).update({
      'favoriteTopics': FieldValue.arrayRemove([topicId])
    });
  }

  Future<void> addLikedEntry(String userId, String entryId) async {
    await firestore.collection(collection).doc(userId).update({
      'likedEntries': FieldValue.arrayUnion([entryId])
    });
  }

  Future<void> removeLikedEntry(String userId, String entryId) async {
    await firestore.collection(collection).doc(userId).update({
      'likedEntries': FieldValue.arrayRemove([entryId])
    });
  }

  Future<void> addDislikedEntry(String userId, String entryId) async {
    await firestore.collection(collection).doc(userId).update({
      'dislikedEntries': FieldValue.arrayUnion([entryId])
    });
  }

  Future<void> removeDislikedEntry(String userId, String entryId) async {
    await firestore.collection(collection).doc(userId).update({
      'dislikedEntries': FieldValue.arrayRemove([entryId])
    });
  }
}
