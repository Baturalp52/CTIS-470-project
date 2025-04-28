import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry_model.dart';
import '../providers/auth_provider.dart';
import '../providers/entry_provider.dart';
import '../services/entry_service.dart';
import '../utils/time_formatter.dart';
import '../screens/user_profile_screen.dart';
import '../screens/entry_create_screen.dart';
import 'like_button.dart';
import 'dislike_button.dart';

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
  late EntryModel _currentEntry;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
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

  void _updateEntry(EntryModel updatedEntry) {
    setState(() {
      _currentEntry = updatedEntry;
    });
  }

  Future<void> _handleEdit() async {
    final entryService = Provider.of<EntryService>(context, listen: false);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryCreateScreen(entry: _currentEntry),
      ),
    );

    if (result != null && result['isEdit'] == true && mounted) {
      try {
        final updatedEntry = EntryModel(
          id: result['entryId'],
          content: result['content'],
          topicId: _currentEntry.topicId,
          createdBy: _currentEntry.createdBy,
          likedBy: _currentEntry.likedBy,
          dislikedBy: _currentEntry.dislikedBy,
        );
        await entryService.updateEntry(updatedEntry);
        // Refresh entries after editing
        if (mounted) {
          await Provider.of<EntryProvider>(context, listen: false)
              .refreshEntries(_currentEntry.topicId);
        }
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
        await entryService.delete(EntryService.collection, _currentEntry.id!);
        // Refresh entries after deletion
        if (mounted) {
          await Provider.of<EntryProvider>(context, listen: false)
              .refreshEntries(_currentEntry.topicId);
        }
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
    if (_currentEntry.creator == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userData: _currentEntry.creator!,
          isCurrentUser: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid;
    final isOwner = currentUserId == _currentEntry.createdBy;

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
                    child: Text(_currentEntry.content,
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
                      'by ${_currentEntry.creator?.displayName ?? _currentEntry.createdBy}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Text(
                    TimeFormatter.formatTime(
                        _currentEntry.createdAt ?? DateTime.now()),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  LikeButton(
                    entryId: _currentEntry.id!,
                    topicId: _currentEntry.topicId,
                    isDisabled: _isDeleting,
                    entry: _currentEntry,
                    onEntryUpdated: _updateEntry,
                  ),
                  const SizedBox(width: 16),
                  DislikeButton(
                    entryId: _currentEntry.id!,
                    topicId: _currentEntry.topicId,
                    isDisabled: _isDeleting,
                    entry: _currentEntry,
                    onEntryUpdated: _updateEntry,
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
      key: Key(_currentEntry.id ?? _currentEntry.hashCode.toString()),
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
          await _handleEdit();
          return false;
        } else {
          await _handleDelete();
          return false;
        }
      },
      child: content,
    );
  }
}
