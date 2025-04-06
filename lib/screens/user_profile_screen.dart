import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/topic_model.dart';
import '../models/entry_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/entry_card.dart';
import 'topic_entries_screen.dart';
import 'settings_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final UserModel userData;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userData,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    // Sample data for user's entries grouped by topics
    // In a real app, this would come from a database or API
    final Map<TopicModel, List<EntryModel>> userEntriesByTopic = {
      TopicModel(
        title: "Computer Networks",
        entryCount: 3,
        createdBy: userData.id!,
        description: "Discussions about network protocols",
      ): [
        EntryModel(
          term: "Understanding TCP/IP protocol stack",
          definition: "A detailed explanation of the TCP/IP protocol stack",
          topicId: "1",
          createdBy: userData.id!,
          likes: 5,
          dislikes: 0,
        ),
        EntryModel(
          term: "Network security best practices",
          definition: "Essential security practices for network administrators",
          topicId: "1",
          createdBy: userData.id!,
          likes: 8,
          dislikes: 1,
        ),
      ],
      TopicModel(
        title: "Operating Systems",
        entryCount: 2,
        createdBy: userData.id!,
        description: "OS concepts and memory management",
      ): [
        EntryModel(
          term: "Process scheduling algorithms",
          definition: "Different approaches to process scheduling in OS",
          topicId: "2",
          createdBy: userData.id!,
          likes: 12,
          dislikes: 2,
        ),
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isCurrentUser ? 'Profile' : userData.displayName ?? 'Anonymous'),
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
          ProfileHeader(userData: userData),
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
