import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class EntryModel extends BaseModel {
  String term;
  String definition;
  String topicId;
  String createdBy;
  int likes;
  int dislikes;
  List<String>? tags;
  String? imageUrl;
  String? example;
  List<String> likedBy;
  List<String> dislikedBy;

  EntryModel({
    String? id,
    required this.term,
    required this.definition,
    required this.topicId,
    required this.createdBy,
    this.likes = 0,
    this.dislikes = 0,
    this.tags,
    this.imageUrl,
    this.example,
    this.likedBy = const [],
    this.dislikedBy = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory EntryModel.fromMap(Map<String, dynamic> map, String id) {
    return EntryModel(
      id: id,
      term: map['term'],
      definition: map['definition'],
      topicId: map['topicId'],
      createdBy: map['createdBy'],
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      imageUrl: map['imageUrl'],
      example: map['example'],
      likedBy: List<String>.from(map['likedBy'] ?? []),
      dislikedBy: List<String>.from(map['dislikedBy'] ?? []),
      createdAt: BaseModel.fromTimestamp(map['createdAt']),
      updatedAt: BaseModel.fromTimestamp(map['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    updateTimestamps();
    return {
      'term': term,
      'definition': definition,
      'topicId': topicId,
      'createdBy': createdBy,
      'likes': likes,
      'dislikes': dislikes,
      'tags': tags,
      'imageUrl': imageUrl,
      'example': example,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'createdAt': BaseModel.toTimestamp(createdAt),
      'updatedAt': BaseModel.toTimestamp(updatedAt),
    };
  }

  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isDislikedBy(String userId) => dislikedBy.contains(userId);
}
