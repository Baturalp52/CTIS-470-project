import 'base_model.dart';
import 'user_model.dart';

class EntryModel extends BaseModel {
  String content;
  String topicId;
  String createdBy;
  List<String> likedBy;
  List<String> dislikedBy;
  UserModel? creator;

  EntryModel({
    String? id,
    required this.content,
    required this.topicId,
    required this.createdBy,
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
      content: map['content'],
      topicId: map['topicId'],
      createdBy: map['createdBy'],
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
      'content': content,
      'topicId': topicId,
      'createdBy': createdBy,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'createdAt': BaseModel.toTimestamp(createdAt),
      'updatedAt': BaseModel.toTimestamp(updatedAt),
    };
  }

  int get likes => likedBy.length;
  int get dislikes => dislikedBy.length;

  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isDislikedBy(String userId) => dislikedBy.contains(userId);
}
