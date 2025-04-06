import 'dart:async';
import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../utils/time_formatter.dart';

class EntryCard extends StatefulWidget {
  final Entry entry;

  const EntryCard({super.key, required this.entry});

  @override
  State<EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<EntryCard> {
  late Entry _entry;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Force rebuild to update time display
        });
      }
    });
  }

  void _handleLike() {
    setState(() {
      if (_entry.userReaction == EntryReaction.liked) {
        // Remove like
        _entry.userReaction = EntryReaction.none;
        _entry.likes--;
      } else {
        // Add like and remove dislike if exists
        if (_entry.userReaction == EntryReaction.disliked) {
          _entry.dislikes--;
        }
        _entry.userReaction = EntryReaction.liked;
        _entry.likes++;
      }
    });
  }

  void _handleDislike() {
    setState(() {
      if (_entry.userReaction == EntryReaction.disliked) {
        // Remove dislike
        _entry.userReaction = EntryReaction.none;
        _entry.dislikes--;
      } else {
        // Add dislike and remove like if exists
        if (_entry.userReaction == EntryReaction.liked) {
          _entry.likes--;
        }
        _entry.userReaction = EntryReaction.disliked;
        _entry.dislikes++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_entry.content, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'by ${_entry.author}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    TimeFormatter.formatTime(_entry.createdAt),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.thumb_up_outlined,
                      color:
                          _entry.userReaction == EntryReaction.liked
                              ? Colors.green
                              : Colors.grey,
                    ),
                    onPressed: _handleLike,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_entry.likes}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.thumb_down_outlined,
                      color:
                          _entry.userReaction == EntryReaction.disliked
                              ? Colors.red
                              : Colors.grey,
                    ),
                    onPressed: _handleDislike,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_entry.dislikes}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
