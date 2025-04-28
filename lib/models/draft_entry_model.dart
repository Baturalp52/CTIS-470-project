import 'base_model.dart';

class DraftEntryModel extends BaseModel {
  String content;
  String topicId;
  String createdBy;

  DraftEntryModel({
    super.id,
    required this.content,
    required this.topicId,
    required this.createdBy,
    super.createdAt,
    super.updatedAt,
  }) : super();

  factory DraftEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return DraftEntryModel(
      id: id,
      content: map['content'] ?? '',
      topicId: map['topicId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    updateTimestamps();
    return {
      'id': id,
      'content': content,
      'topicId': topicId,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
