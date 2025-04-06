import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/topic_model.dart';
import '../models/entry_model.dart';
import '../providers/topic_provider.dart';
import '../services/entry_service.dart';
import '../widgets/entry_card.dart';
import 'entry_create_screen.dart';
import 'topic_create_screen.dart';

class TopicEntriesScreen extends StatefulWidget {
  final TopicModel topic;

  const TopicEntriesScreen({super.key, required this.topic});

  @override
  State<TopicEntriesScreen> createState() => _TopicEntriesScreenState();
}

class _TopicEntriesScreenState extends State<TopicEntriesScreen> {
  late TopicModel _currentTopic;
  bool _isDeleting = false;
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

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topic;
  }

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
            topicId: _currentTopic.id!,
            createdBy: 'currentUser', // TODO: Replace with actual user
            likes: 0,
            dislikes: 0,
          ),
        );
      });
    }
  }

  void _navigateToEditTopic() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicCreateScreen(topic: _currentTopic),
      ),
    );

    // After returning from edit screen, update the current topic
    final topicProvider = Provider.of<TopicProvider>(context, listen: false);
    final updatedTopic =
        topicProvider.topics.where((t) => t.id == _currentTopic.id).firstOrNull;

    if (updatedTopic != null) {
      setState(() {
        _currentTopic = updatedTopic;
      });
    }
  }

  Future<void> _deleteTopic() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic'),
        content: const Text(
          'Are you sure you want to delete this topic? This will also delete all entries in this topic. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isDeleting = true;
      });

      final topicProvider = Provider.of<TopicProvider>(context, listen: false);
      final entryService = Provider.of<EntryService>(context, listen: false);

      try {
        // First delete all entries in this topic
        final entries =
            await entryService.streamEntries(topicId: _currentTopic.id).first;
        for (final entry in entries) {
          if (entry.id != null) {
            await entryService.delete(EntryService.collection, entry.id!);
          }
        }

        // Then delete the topic
        final success = await topicProvider.deleteTopic(_currentTopic.id!);
        if (success && mounted) {
          Navigator.pop(context); // Return to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete topic: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicProvider = Provider.of<TopicProvider>(context);
    final canEdit =
        topicProvider.topics.where((t) => t.id == _currentTopic.id).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentTopic.title),
            Text(
              '${entries.length} entries',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditTopic,
            ),
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.delete),
              onPressed: _isDeleting ? null : _deleteTopic,
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return EntryCard(entry: entries[index]);
            },
          ),
          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isDeleting ? null : _navigateToCreateEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
