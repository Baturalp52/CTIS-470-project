import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseModel {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;

  BaseModel({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap();

  static DateTime? fromTimestamp(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  static Timestamp? toTimestamp(DateTime? date) {
    return date != null ? Timestamp.fromDate(date) : null;
  }

  void updateTimestamps() {
    final now = DateTime.now();
    createdAt ??= now;
    updatedAt = now;
  }
}
