import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import '../widgets/entry_card.dart';
import '../services/topic_service.dart';
import '../services/entry_service.dart';
import 'package:provider/provider.dart';
import '../screens/topic_entries_screen.dart';

class UserEntriesTab extends StatelessWidget {
  final String userId;
  final UserModel currentUserData;

  const UserEntriesTab({
    super.key,
    required this.userId,
    required this.currentUserData,
  });

  @override
  Widget build(BuildContext context) {
    final topicService = Provider.of<TopicService>(context);
    final entryService = Provider.of<EntryService>(context);

    return StreamBuilder<List<TopicModel>>(
      stream: topicService.streamTopics(createdBy: userId),
      builder: (context, topicSnapshot) {
        if (topicSnapshot.hasError) {
          return Center(child: Text('Error: ${topicSnapshot.error}'));
        }

        if (!topicSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<EntryModel>>(
          stream: entryService.streamEntries(createdBy: userId),
          builder: (context, entrySnapshot) {
            if (entrySnapshot.hasError) {
              return Center(child: Text('Error: ${entrySnapshot.error}'));
            }

            if (!entrySnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final topics = topicSnapshot.data!;
            final entries = entrySnapshot.data!;
            final Map<TopicModel, List<EntryModel>> updatedEntriesByTopic = {};

            // Set creator for all entries
            final updatedEntries = entries.map((entry) {
              entry.creator = currentUserData;
              return entry;
            }).toList();

            for (final topic in topics) {
              final topicEntries = updatedEntries
                  .where((entry) => entry.topicId == topic.id)
                  .toList();
              if (topicEntries.isNotEmpty) {
                updatedEntriesByTopic[topic] = topicEntries;
              }
            }

            if (updatedEntriesByTopic.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No entries found'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: updatedEntriesByTopic.length,
              itemBuilder: (context, index) {
                final topic = updatedEntriesByTopic.keys.elementAt(index);
                final entries = updatedEntriesByTopic[topic]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TopicEntriesScreen(topic: topic),
                            ),
                          );
                          if (result == true) {
                            // Refresh data if topic was deleted
                            // You might want to implement a callback here
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${entries.length} entries',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...entries.map((entry) => EntryCard(entry: entry)),
                    const Divider(height: 1),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
