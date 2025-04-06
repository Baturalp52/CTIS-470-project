import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/base_model.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> create<T extends BaseModel>(String collection, T model) async {
    model.updateTimestamps();
    final docRef = await firestore.collection(collection).add(model.toMap());
    return docRef.id;
  }

  Future<void> update<T extends BaseModel>(
      String collection, String id, T model) async {
    model.updateTimestamps();
    await firestore.collection(collection).doc(id).update(model.toMap());
  }

  Future<void> delete(String collection, String id) async {
    await firestore.collection(collection).doc(id).delete();
  }

  Future<T?> get<T extends BaseModel>(String collection, String id,
      T Function(Map<String, dynamic>, String) fromMap) async {
    final doc = await firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return fromMap(doc.data()!, doc.id);
  }

  Stream<List<T>> streamCollection<T extends BaseModel>(
    String collection,
    T Function(Map<String, dynamic>, String) fromMap, {
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)?
        queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromMap(doc.data(), doc.id)).toList();
    });
  }
}
