import 'base_model.dart';

class UserModel extends BaseModel {
  String? email;
  String? displayName;
  String? photoURL;
  String? bio;

  UserModel({
    super.id,
    this.email,
    this.displayName,
    this.photoURL,
    this.bio,
    super.createdAt,
    super.updatedAt,
  }) : super();

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      bio: map['bio'],
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
      'createdAt': BaseModel.toTimestamp(createdAt),
      'updatedAt': BaseModel.toTimestamp(updatedAt),
    };
  }
}
