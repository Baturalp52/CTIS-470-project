import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/topic.dart';
import '../models/entry.dart';
import '../widgets/profile_header.dart';
import '../widgets/entry_card.dart';
import 'topic_entries_screen.dart';
import 'settings_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final User user;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    // Sample data for user's entries grouped by topics
    // In a real app, this would come from a database or API
    final Map<Topic, List<Entry>> userEntriesByTopic = {
      Topic(
        title: "Computer Networks",
        entryCount: 3,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
        description: "Discussions about network protocols",
      ): [
        Entry(
          content: "Understanding TCP/IP protocol stack",
          author: user.name,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          likes: 5,
          dislikes: 0,
          userReaction: EntryReaction.liked,
        ),
        Entry(
          content: "Network security best practices",
          author: user.name,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          likes: 8,
          dislikes: 1,
          userReaction: EntryReaction.none,
        ),
      ],
      Topic(
        title: "Operating Systems",
        entryCount: 2,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 5)),
        description: "OS concepts and memory management",
      ): [
        Entry(
          content: "Process scheduling algorithms",
          author: user.name,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          likes: 12,
          dislikes: 2,
          userReaction: EntryReaction.liked,
        ),
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'Profile' : user.name),
        actions: isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          ProfileHeader(user: user),
          Expanded(
            child: ListView.builder(
              itemCount: userEntriesByTopic.length,
              itemBuilder: (context, index) {
                final topic = userEntriesByTopic.keys.elementAt(index);
                final entries = userEntriesByTopic[topic]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TopicEntriesScreen(topic: topic),
                            ),
                          );
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
                    // Entries List
                    ...entries.map((entry) => EntryCard(entry: entry)),
                    const Divider(height: 1),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
