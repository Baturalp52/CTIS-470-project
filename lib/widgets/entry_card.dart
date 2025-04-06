import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import '../utils/time_formatter.dart';
import '../screens/user_profile_screen.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

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
  late EntryModel _entry;
  Timer? _timer;
  UserModel? _creator;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
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
      final creator = await _userService.getUser(_entry.createdBy);
      if (mounted) {
        setState(() {
          _creator = creator;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _handleLike() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    if (currentUserId == null) return;

    setState(() {
      if (_entry.isLikedBy(currentUserId)) {
        // Remove like
        _entry.likedBy.remove(currentUserId);
        _entry.likes--;
      } else {
        // Add like and remove dislike if exists
        if (_entry.isDislikedBy(currentUserId)) {
          _entry.dislikedBy.remove(currentUserId);
          _entry.dislikes--;
        }
        _entry.likedBy.add(currentUserId);
        _entry.likes++;
      }
    });
  }

  void _handleDislike() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    if (currentUserId == null) return;

    setState(() {
      if (_entry.isDislikedBy(currentUserId)) {
        // Remove dislike
        _entry.dislikedBy.remove(currentUserId);
        _entry.dislikes--;
      } else {
        // Add dislike and remove like if exists
        if (_entry.isLikedBy(currentUserId)) {
          _entry.likedBy.remove(currentUserId);
          _entry.likes--;
        }
        _entry.dislikedBy.add(currentUserId);
        _entry.dislikes++;
      }
    });
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
    final currentUserId = authProvider.user?.uid;
    final isLiked = currentUserId != null && _entry.isLikedBy(currentUserId);
    final isDisliked =
        currentUserId != null && _entry.isDislikedBy(currentUserId);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_entry.term, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _navigateToUserProfile,
                    child: Text(
                      'by ${_creator?.displayName ?? _entry.createdBy}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Text(
                    TimeFormatter.formatTime(
                        _entry.createdAt ?? DateTime.now()),
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
                      color: isDisliked ? Colors.red : Colors.grey,
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
