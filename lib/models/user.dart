class User {
  final String id;
  String name;
  String email;
  String? profileImageUrl;
  String? bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
  });
}
