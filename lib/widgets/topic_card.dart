import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/topic_model.dart';
import '../services/topic_service.dart';
import '../utils/time_formatter.dart';

class TopicCard extends StatelessWidget {
  final TopicModel topic;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TopicCard({
    super.key,
    required this.topic,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final topicService = Provider.of<TopicService>(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  topic.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    FutureBuilder<int>(
                      future: topicService.getEntryCount(topic.id!),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Text(
                          '$count entries',
                          style: TextStyle(color: Colors.grey[600]),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Last updated: ${TimeFormatter.formatTime(topic.updatedAt ?? DateTime.now())}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
