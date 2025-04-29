import 'base_model.dart';

class TopicModel extends BaseModel {
  String title;
  String description;
  String createdBy;
  String? imageBase64;

  TopicModel({
    super.id,
    required this.title,
    required this.description,
    required this.createdBy,
    this.imageBase64,
    super.createdAt,
    super.updatedAt,
  }) : super();

  factory TopicModel.fromMap(Map<String, dynamic> map, String id) {
    return TopicModel(
      id: id,
      title: map['title'],
      description: map['description'],
      createdBy: map['createdBy'],
      imageBase64: map['imageBase64'],
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
      'createdBy': createdBy,
      'imageBase64': imageBase64,
      'createdAt': BaseModel.toTimestamp(createdAt),
      'updatedAt': BaseModel.toTimestamp(updatedAt),
    };
  }
}
