import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class TopicModel extends BaseModel {
  String title;
  String description;
  String? imageUrl;
  int entryCount;
  String createdBy;

  TopicModel({
    String? id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.entryCount = 0,
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory TopicModel.fromMap(Map<String, dynamic> map, String id) {
    return TopicModel(
      id: id,
      title: map['title'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      entryCount: map['entryCount'] ?? 0,
      createdBy: map['createdBy'],
      createdAt: BaseModel.fromTimestamp(map['createdAt']),
      updatedAt: BaseModel.fromTimestamp(map['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    updateTimestamps();
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'entryCount': entryCount,
      'createdBy': createdBy,
      'createdAt': BaseModel.toTimestamp(createdAt),
      'updatedAt': BaseModel.toTimestamp(updatedAt),
    };
  }
}
