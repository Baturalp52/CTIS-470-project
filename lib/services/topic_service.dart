import '../models/topic_model.dart';
import 'firestore_service.dart';
import 'entry_service.dart';

class TopicService extends FirestoreService {
  static const String collection = 'topics';
  final EntryService _entryService = EntryService();

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

  Future<List<TopicModel>> getTopics() async {
    final query =
        firestore.collection(collection).orderBy('createdAt', descending: true);
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => TopicModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<int> getEntryCount(String topicId) async {
    final entries = await _entryService.streamEntries(topicId: topicId).first;
    return entries.length;
  }

  @override
  Future<void> delete(String collection, String id) async {
    await super.delete(collection, id);
  }
}
