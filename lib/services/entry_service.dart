import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entry_model.dart';
import 'firestore_service.dart';

class EntryService extends FirestoreService {
  static const String collection = 'entries';

  Future<String> createEntry(EntryModel entry) async {
    return create(collection, entry);
  }

  Future<void> updateEntry(EntryModel entry) async {
    if (entry.id == null) throw Exception('Entry ID is required for update');
    await update(collection, entry.id!, entry);
  }

  Future<EntryModel?> getEntry(String entryId) async {
    return get(collection, entryId, EntryModel.fromMap);
  }

  Stream<EntryModel?> streamEntry(String entryId) {
    return firestore.collection(collection).doc(entryId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return EntryModel.fromMap(doc.data()!, doc.id);
    });
  }

  Stream<List<EntryModel>> streamEntries({
    String? topicId,
    String? createdBy,
    int? limit,
  }) {
    return streamCollection(
      collection,
      EntryModel.fromMap,
      queryBuilder: (query) {
        if (topicId != null) {
          query = query.where('topicId', isEqualTo: topicId);
        }
        if (createdBy != null) {
          query = query.where('createdBy', isEqualTo: createdBy);
        }
        if (limit != null) {
          query = query.limit(limit);
        }
        return query.orderBy('createdAt', descending: true);
      },
    );
  }

  Future<void> likeEntry(String entryId, String userId) async {
    final entry = await getEntry(entryId);
    if (entry == null) throw Exception('Entry not found');

    // Remove from dislikedBy if exists
    if (entry.dislikedBy.contains(userId)) {
      await firestore.collection(collection).doc(entryId).update({
        'dislikedBy': FieldValue.arrayRemove([userId]),
      });
    }

    // Add to likedBy
    await firestore.collection(collection).doc(entryId).update({
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unlikeEntry(String entryId, String userId) async {
    await firestore.collection(collection).doc(entryId).update({
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> dislikeEntry(String entryId, String userId) async {
    final entry = await getEntry(entryId);
    if (entry == null) throw Exception('Entry not found');

    // Remove from likedBy if exists
    if (entry.likedBy.contains(userId)) {
      await firestore.collection(collection).doc(entryId).update({
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    }

    // Add to dislikedBy
    await firestore.collection(collection).doc(entryId).update({
      'dislikedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> undislikeEntry(String entryId, String userId) async {
    await firestore.collection(collection).doc(entryId).update({
      'dislikedBy': FieldValue.arrayRemove([userId]),
    });
  }
}
