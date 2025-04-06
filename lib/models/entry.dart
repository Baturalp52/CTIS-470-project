enum EntryReaction { none, liked, disliked }

class Entry {
  final String content;
  final String author;
  final DateTime createdAt;
  int likes;
  int dislikes;
  EntryReaction userReaction;

  Entry({
    required this.content,
    required this.author,
    required this.createdAt,
    this.likes = 0,
    this.dislikes = 0,
    this.userReaction = EntryReaction.none,
  });
}
