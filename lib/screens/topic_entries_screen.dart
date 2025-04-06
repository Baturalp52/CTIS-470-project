import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../models/entry_model.dart';
import '../widgets/entry_card.dart';
import 'entry_create_screen.dart';

class TopicEntriesScreen extends StatefulWidget {
  final TopicModel topic;

  const TopicEntriesScreen({super.key, required this.topic});

  @override
  State<TopicEntriesScreen> createState() => _TopicEntriesScreenState();
}

class _TopicEntriesScreenState extends State<TopicEntriesScreen> {
  final List<EntryModel> entries = [
    EntryModel(
      term: 'Just posted this entry a few seconds ago!',
      definition: 'A detailed explanation of the term',
      topicId: '1',
      createdBy: 'user1',
      likes: 0,
      dislikes: 0,
    ),
    EntryModel(
      term: 'This entry was posted 5 minutes ago.',
      definition: 'Another detailed explanation',
      topicId: '1',
      createdBy: 'user2',
      likes: 2,
      dislikes: 0,
    ),
    EntryModel(
      term: 'This entry was posted 45 minutes ago.',
      definition: 'Yet another detailed explanation',
      topicId: '1',
      createdBy: 'user3',
      likes: 5,
      dislikes: 1,
    ),
    EntryModel(
      term: 'This entry was posted 2 hours ago.',
      definition: 'A comprehensive explanation',
      topicId: '1',
      createdBy: 'user4',
      likes: 8,
      dislikes: 2,
    ),
    EntryModel(
      term: 'This entry was posted 12 hours ago.',
      definition: 'An in-depth explanation',
      topicId: '1',
      createdBy: 'user5',
      likes: 15,
      dislikes: 3,
    ),
    EntryModel(
      term: 'This entry was posted 1 day ago.',
      definition: 'A thorough explanation',
      topicId: '1',
      createdBy: 'user6',
      likes: 20,
      dislikes: 4,
    ),
    EntryModel(
      term: 'This entry was posted 3 days ago.',
      definition: 'A complete explanation',
      topicId: '1',
      createdBy: 'user7',
      likes: 25,
      dislikes: 5,
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
          EntryModel(
            term: result['term'],
            definition: result['definition'],
            topicId: widget.topic.id!,
            createdBy: 'currentUser', // TODO: Replace with actual user
            likes: 0,
            dislikes: 0,
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
