import 'package:flutter/material.dart';
import '../models/topic_model.dart';
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
  final List<TopicModel> topics = [
    TopicModel(
      title: "Computer Networks",
      entryCount: 45,
      createdBy: 'user1',
      description:
          "Discussions about network protocols, architectures, and implementations",
    ),
    TopicModel(
      title: "Operating Systems",
      entryCount: 38,
      createdBy: 'user1',
      description:
          "Everything about OS concepts, processes, and memory management",
    ),
    TopicModel(
      title: "Database Systems",
      entryCount: 52,
      createdBy: 'user1',
      description: "SQL, NoSQL, and database design principles",
    ),
    TopicModel(
      title: "Software Engineering",
      entryCount: 67,
      createdBy: 'user1',
      description: "Software development methodologies and best practices",
    ),
    TopicModel(
      title: "Artificial Intelligence",
      entryCount: 89,
      createdBy: 'user1',
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
          TopicModel(
            title: result['title'],
            description: result['description'],
            entryCount: result['entryCount'],
            createdBy: 'user1',
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
                  builder: (context) =>
                      TopicEntriesScreen(topic: topics[index]),
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
