import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/topic_model.dart';
import '../models/entry_model.dart';
import '../providers/topic_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/entry_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topic;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EntryProvider>(context, listen: false)
          .loadEntries(_currentTopic.id!);
    });
  }

  void _navigateToCreateEntry() async {
    final entryService = Provider.of<EntryService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    if (currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to create an entry')),
        );
      }
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EntryCreateScreen()),
    );

    if (result != null && mounted) {
      try {
        final entry = EntryModel(
          content: result['content'],
          topicId: _currentTopic.id!,
          createdBy: currentUserId,
        );
        await entryService.createEntry(entry);
        // Refresh entries after creating
        if (mounted) {
          await Provider.of<EntryProvider>(context, listen: false)
              .refreshEntries(_currentTopic.id!);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create entry: $e')),
          );
        }
      }
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
    if (!mounted) return;
    final topicProvider = Provider.of<TopicProvider>(context, listen: false);
    final updatedTopic =
        topicProvider.topics.where((t) => t.id == _currentTopic.id).firstOrNull;

    if (updatedTopic != null && mounted) {
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

    if (confirmed == true && mounted) {
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
          Navigator.pop(
              context, true); // Return to previous screen with success
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
    final entryProvider = Provider.of<EntryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid;
    final canEdit = currentUserId == _currentTopic.createdBy;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentTopic.title),
            Text(
              '${entryProvider.entries.length} entries',
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
      body: entryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : entryProvider.error != null
              ? Center(child: Text(entryProvider.error!))
              : Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () =>
                          entryProvider.refreshEntries(_currentTopic.id!),
                      child: entryProvider.entries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'No entries found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _isDeleting
                                        ? null
                                        : _navigateToCreateEntry,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Entry'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: entryProvider.entries.length,
                              itemBuilder: (context, index) {
                                return EntryCard(
                                    entry: entryProvider.entries[index]);
                              },
                            ),
                    ),
                    if (_isDeleting)
                      Container(
                        color: Colors.black.withAlpha(77),
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
