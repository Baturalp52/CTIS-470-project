import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/topic_model.dart';
import '../providers/topic_provider.dart';
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
  @override
  void initState() {
    super.initState();
    // Load topics when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TopicProvider>(context, listen: false).loadTopics();
    });
  }

  void _navigateToCreateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TopicCreateScreen()),
    );
  }

  void _navigateToEditScreen(TopicModel topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicCreateScreen(topic: topic),
      ),
    );
  }

  Future<void> _deleteTopic(TopicModel topic) async {
    final topicProvider = Provider.of<TopicProvider>(context, listen: false);
    final success = await topicProvider.deleteTopic(topic.id!);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(topicProvider.error ?? 'Failed to delete topic')),
      );
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
      body: Consumer<TopicProvider>(
        builder: (context, topicProvider, child) {
          if (topicProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (topicProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(topicProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => topicProvider.loadTopics(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (topicProvider.topics.isEmpty) {
            return const Center(
              child: Text('No topics found. Create your first topic!'),
            );
          }

          return ListView.builder(
            itemCount: topicProvider.topics.length,
            itemBuilder: (context, index) {
              final topic = topicProvider.topics[index];
              return TopicCard(
                topic: topic,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicEntriesScreen(topic: topic),
                    ),
                  );
                },
                onEdit: () => _navigateToEditScreen(topic),
                onDelete: () => _deleteTopic(topic),
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
