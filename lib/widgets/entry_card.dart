import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry_model.dart';
import '../utils/time_formatter.dart';
import '../screens/user_profile_screen.dart';
import '../screens/entry_create_screen.dart';
import '../providers/auth_provider.dart';
import '../services/entry_service.dart';

class EntryCard extends StatefulWidget {
  final EntryModel entry;

  const EntryCard({
    super.key,
    required this.entry,
  });

  @override
  State<EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<EntryCard> {
  Timer? _timer;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _handleLike() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryService = Provider.of<EntryService>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    if (currentUserId == null) return;

    try {
      if (widget.entry.isLikedBy(currentUserId)) {
        await entryService.unlikeEntry(widget.entry.id!, currentUserId);
      } else {
        await entryService.likeEntry(widget.entry.id!, currentUserId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update like: $e')),
        );
      }
    }
  }

  Future<void> _handleDislike() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryService = Provider.of<EntryService>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    if (currentUserId == null) return;

    try {
      if (widget.entry.isDislikedBy(currentUserId)) {
        await entryService.undislikeEntry(widget.entry.id!, currentUserId);
      } else {
        await entryService.dislikeEntry(widget.entry.id!, currentUserId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update dislike: $e')),
        );
      }
    }
  }

  Future<void> _handleEdit() async {
    final entryService = Provider.of<EntryService>(context, listen: false);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryCreateScreen(entry: widget.entry),
      ),
    );

    if (result != null && result['isEdit'] == true && mounted) {
      try {
        final updatedEntry = EntryModel(
          id: result['entryId'],
          content: result['content'],
          topicId: widget.entry.topicId,
          createdBy: widget.entry.createdBy,
          likedBy: widget.entry.likedBy,
          dislikedBy: widget.entry.dislikedBy,
        );
        await entryService.updateEntry(updatedEntry);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update entry: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleDelete() async {
    final entryService = Provider.of<EntryService>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
            'Are you sure you want to delete this entry? This action cannot be undone.'),
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
      setState(() => _isDeleting = true);
      try {
        await entryService.delete(EntryService.collection, widget.entry.id!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete entry: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  void _navigateToUserProfile() {
    if (widget.entry.creator == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userData: widget.entry.creator!,
          isCurrentUser: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final entryService = Provider.of<EntryService>(context);
    final currentUserId = authProvider.user?.uid;
    final isOwner = currentUserId == widget.entry.createdBy;

    return StreamBuilder<EntryModel?>(
      stream: entryService.getEntry(widget.entry.id!).asStream(),
      builder: (context, snapshot) {
        final entry = snapshot.data ?? widget.entry;
        final isLiked = currentUserId != null && entry.isLikedBy(currentUserId);
        final isDisliked =
            currentUserId != null && entry.isDislikedBy(currentUserId);

        final content = Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(entry.content,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _navigateToUserProfile,
                        child: Text(
                          'by ${widget.entry.creator?.displayName ?? entry.createdBy}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      Text(
                        TimeFormatter.formatTime(
                            entry.createdAt ?? DateTime.now()),
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
                          color: isLiked ? Colors.green : Colors.grey,
                        ),
                        onPressed: _isDeleting ? null : _handleLike,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.likes}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_down_outlined,
                          color: isDisliked ? Colors.red : Colors.grey,
                        ),
                        onPressed: _isDeleting ? null : _handleDislike,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.dislikes}',
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

        if (!isOwner) {
          return content;
        }

        return Dismissible(
          key: Key(entry.id ?? entry.hashCode.toString()),
          direction: DismissDirection.horizontal,
          background: Container(
            color: Colors.yellow,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.edit, color: Colors.black),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe right - Edit
              await _handleEdit();
              return false; // Prevent dismissal
            } else {
              // Swipe left - Delete
              await _handleDelete();
              return false; // Prevent dismissal
            }
          },
          child: content,
        );
      },
    );
  }
}
