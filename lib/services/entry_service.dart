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

  Future<void> incrementLikes(String entryId) async {
    await firestore.collection(collection).doc(entryId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> decrementLikes(String entryId) async {
    await firestore.collection(collection).doc(entryId).update({
      'likes': FieldValue.increment(-1),
    });
  }

  Future<void> incrementDislikes(String entryId) async {
    await firestore.collection(collection).doc(entryId).update({
      'dislikes': FieldValue.increment(1),
    });
  }

  Future<void> decrementDislikes(String entryId) async {
    await firestore.collection(collection).doc(entryId).update({
      'dislikes': FieldValue.increment(-1),
    });
  }
}
