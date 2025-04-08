import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/topic_model.dart';
import '../models/entry_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/entry_card.dart';
import '../services/topic_service.dart';
import '../services/entry_service.dart';
import '../services/user_service.dart';
import 'topic_entries_screen.dart';
import 'settings_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel userData;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userData,
    this.isCurrentUser = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<TopicModel, List<EntryModel>> _userEntriesByTopic = {};
  bool _isLoading = true;
  String? _error;
  late UserModel _currentUserData;

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.userData;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final topicService = Provider.of<TopicService>(context, listen: false);
      final entryService = Provider.of<EntryService>(context, listen: false);

      // Get updated user data
      if (widget.isCurrentUser) {
        final updatedUser = await userService.getUser(_currentUserData.id!);
        if (updatedUser != null) {
          setState(() {
            _currentUserData = updatedUser;
          });
        }
      }

      // Get all topics created by the user
      final topics = await topicService
          .streamTopics(
            createdBy: _currentUserData.id!,
          )
          .first;

      // Get all entries created by the user
      final entries = await entryService
          .streamEntries(
            createdBy: _currentUserData.id!,
          )
          .first;

      // Group entries by topic
      final Map<TopicModel, List<EntryModel>> entriesByTopic = {};
      for (final topic in topics) {
        final topicEntries =
            entries.where((entry) => entry.topicId == topic.id).toList();
        if (topicEntries.isNotEmpty) {
          entriesByTopic[topic] = topicEntries;
        }
      }

      setState(() {
        _userEntriesByTopic = entriesByTopic;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final topicService = Provider.of<TopicService>(context);
    final entryService = Provider.of<EntryService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCurrentUser
            ? 'Profile'
            : _currentUserData.displayName ?? 'Anonymous'),
        actions: widget.isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                    // Refresh user data after returning from settings
                    _refreshData();
                  },
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ProfileHeader(userData: _currentUserData),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _userEntriesByTopic.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No entries found'),
                              ),
                            )
                          : StreamBuilder<List<TopicModel>>(
                              stream: topicService.streamTopics(
                                createdBy: _currentUserData.id!,
                              ),
                              builder: (context, topicSnapshot) {
                                if (topicSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${topicSnapshot.error}'));
                                }

                                if (!topicSnapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                return StreamBuilder<List<EntryModel>>(
                                  stream: entryService.streamEntries(
                                    createdBy: _currentUserData.id!,
                                  ),
                                  builder: (context, entrySnapshot) {
                                    if (entrySnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error: ${entrySnapshot.error}'));
                                    }

                                    if (!entrySnapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    // Update entries by topic with new data
                                    final topics = topicSnapshot.data!;
                                    final entries = entrySnapshot.data!;
                                    final Map<TopicModel, List<EntryModel>>
                                        updatedEntriesByTopic = {};

                                    // Set creator for all entries
                                    final updatedEntries = entries.map((entry) {
                                      entry.creator = _currentUserData;
                                      return entry;
                                    }).toList();

                                    for (final topic in topics) {
                                      final topicEntries = updatedEntries
                                          .where((entry) =>
                                              entry.topicId == topic.id)
                                          .toList();
                                      if (topicEntries.isNotEmpty) {
                                        updatedEntriesByTopic[topic] =
                                            topicEntries;
                                      }
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: updatedEntriesByTopic.length,
                                      itemBuilder: (context, index) {
                                        final topic = updatedEntriesByTopic.keys
                                            .elementAt(index);
                                        final entries =
                                            updatedEntriesByTopic[topic]!;

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Topic Header
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  final result =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TopicEntriesScreen(
                                                              topic: topic),
                                                    ),
                                                  );
                                                  if (result == true) {
                                                    // Refresh data if topic was deleted
                                                    _refreshData();
                                                  }
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      topic.title,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      topic.description,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.color,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.edit,
                                                            size: 16,
                                                            color: Colors
                                                                .grey[600]),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          '${entries.length} entries',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[600]),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Entries List
                                            ...entries.map((entry) =>
                                                EntryCard(entry: entry)),
                                            const Divider(height: 1),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
            ],
          ),
        ),
      ),
    );
  }
}
