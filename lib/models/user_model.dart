import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class UserModel extends BaseModel {
  String? email;
  String? displayName;
  String? photoURL;
  String? bio;
  List<String>? favoriteTopics;
  List<String>? likedEntries;
  List<String>? dislikedEntries;

  UserModel({
    String? id,
    this.email,
    this.displayName,
    this.photoURL,
    this.bio,
    this.favoriteTopics,
    this.likedEntries,
    this.dislikedEntries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      bio: map['bio'],
      favoriteTopics: List<String>.from(map['favoriteTopics'] ?? []),
      likedEntries: List<String>.from(map['likedEntries'] ?? []),
      dislikedEntries: List<String>.from(map['dislikedEntries'] ?? []),
      createdAt: BaseModel.fromTimestamp(map['createdAt']),
      updatedAt: BaseModel.fromTimestamp(map['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    updateTimestamps();
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'favoriteTopics': favoriteTopics,
      'likedEntries': likedEntries,
      'dislikedEntries': dislikedEntries,
      'createdAt': BaseModel.toTimestamp(createdAt),
      'updatedAt': BaseModel.toTimestamp(updatedAt),
    };
  }
}
