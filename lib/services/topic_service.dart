import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic_model.dart';
import 'firestore_service.dart';

class TopicService extends FirestoreService {
  static const String collection = 'topics';

  Future<String> createTopic(TopicModel topic) async {
    return create(collection, topic);
  }

  Future<void> updateTopic(TopicModel topic) async {
    if (topic.id == null) throw Exception('Topic ID is required for update');
    await update(collection, topic.id!, topic);
  }

  Future<TopicModel?> getTopic(String topicId) async {
    return get(collection, topicId, TopicModel.fromMap);
  }

  Stream<List<TopicModel>> streamTopics({
    String? createdBy,
    int? limit,
  }) {
    return streamCollection(
      collection,
      TopicModel.fromMap,
      queryBuilder: (query) {
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

  Future<void> incrementEntryCount(String topicId) async {
    await firestore.collection(collection).doc(topicId).update({
      'entryCount': FieldValue.increment(1),
    });
  }

  Future<void> decrementEntryCount(String topicId) async {
    await firestore.collection(collection).doc(topicId).update({
      'entryCount': FieldValue.increment(-1),
    });
  }
}
