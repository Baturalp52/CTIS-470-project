import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import '../utils/time_formatter.dart';
import '../screens/user_profile_screen.dart';
import '../screens/entry_create_screen.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
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
  UserModel? _creator;
  bool _isDeleting = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadCreatorData();
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

  Future<void> _loadCreatorData() async {
    try {
      final creator = await _userService.getUser(widget.entry.createdBy);
      if (mounted) {
        setState(() {
          _creator = creator;
        });
      }
    } catch (e) {
      // Handle error silently
    }
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryCreateScreen(entry: widget.entry),
      ),
    );

    if (result != null && result['isEdit'] == true) {
      final entryService = Provider.of<EntryService>(context, listen: false);
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

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      final entryService = Provider.of<EntryService>(context, listen: false);
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
    if (_creator == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userData: _creator!,
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

        return Column(
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
                      if (isOwner && !_isDeleting)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit,
                                  size: 20,
                                  color: Theme.of(context).primaryColor),
                              onPressed: _handleEdit,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: _handleDelete,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
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
                          'by ${_creator?.displayName ?? entry.createdBy}',
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
      },
    );
  }
}
