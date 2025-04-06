import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../models/entry.dart';
import '../widgets/entry_card.dart';
import 'entry_create_screen.dart';

class TopicEntriesScreen extends StatefulWidget {
  final Topic topic;

  const TopicEntriesScreen({super.key, required this.topic});

  @override
  State<TopicEntriesScreen> createState() => _TopicEntriesScreenState();
}

class _TopicEntriesScreenState extends State<TopicEntriesScreen> {
  final List<Entry> entries = [
    Entry(
      content: 'Just posted this entry a few seconds ago!',
      author: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
      likes: 0,
      dislikes: 0,
      userReaction: EntryReaction.none,
    ),
    Entry(
      content: 'This entry was posted 5 minutes ago.',
      author: 'Jane Smith',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      likes: 2,
      dislikes: 0,
      userReaction: EntryReaction.liked,
    ),
    Entry(
      content: 'This entry was posted 45 minutes ago.',
      author: 'Mike Johnson',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      likes: 5,
      dislikes: 1,
      userReaction: EntryReaction.disliked,
    ),
    Entry(
      content: 'This entry was posted 2 hours ago.',
      author: 'Sarah Wilson',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 8,
      dislikes: 2,
      userReaction: EntryReaction.liked,
    ),
    Entry(
      content: 'This entry was posted 12 hours ago.',
      author: 'David Brown',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      likes: 15,
      dislikes: 3,
      userReaction: EntryReaction.none,
    ),
    Entry(
      content: 'This entry was posted 1 day ago.',
      author: 'Emily Davis',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 20,
      dislikes: 4,
      userReaction: EntryReaction.disliked,
    ),
    Entry(
      content: 'This entry was posted 3 days ago.',
      author: 'Robert Taylor',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likes: 25,
      dislikes: 5,
      userReaction: EntryReaction.liked,
    ),
  ];

  void _navigateToCreateEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EntryCreateScreen()),
    );

    if (result != null) {
      setState(() {
        entries.add(
          Entry(
            content: result,
            author: 'Current User', // TODO: Replace with actual user
            createdAt: DateTime.now(),
            userReaction: EntryReaction.none,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.topic.title),
            Text(
              '${entries.length} entries',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return EntryCard(entry: entries[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
