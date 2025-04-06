import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../widgets/topic_card.dart';
import 'topic_create_screen.dart';
import 'topic_entries_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Topic> topics = [
    Topic(
      title: "Computer Networks",
      entryCount: 45,
      lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
      description:
          "Discussions about network protocols, architectures, and implementations",
    ),
    Topic(
      title: "Operating Systems",
      entryCount: 38,
      lastUpdate: DateTime.now().subtract(const Duration(hours: 5)),
      description:
          "Everything about OS concepts, processes, and memory management",
    ),
    Topic(
      title: "Database Systems",
      entryCount: 52,
      lastUpdate: DateTime.now().subtract(const Duration(hours: 1)),
      description: "SQL, NoSQL, and database design principles",
    ),
    Topic(
      title: "Software Engineering",
      entryCount: 67,
      lastUpdate: DateTime.now().subtract(const Duration(hours: 3)),
      description: "Software development methodologies and best practices",
    ),
    Topic(
      title: "Artificial Intelligence",
      entryCount: 89,
      lastUpdate: DateTime.now().subtract(const Duration(hours: 4)),
      description: "Machine learning, neural networks, and AI applications",
    ),
  ];

  void _navigateToCreateScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TopicCreateScreen()),
    );

    if (result != null) {
      setState(() {
        topics.add(
          Topic(
            title: result['title'],
            description: result['description'],
            entryCount: result['entryCount'],
            lastUpdate: result['lastUpdate'],
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
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return TopicCard(
            topic: topics[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TopicEntriesScreen(topic: topics[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _navigateToCreateScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
