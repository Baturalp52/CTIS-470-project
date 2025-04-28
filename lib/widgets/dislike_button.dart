import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/entry_service.dart';
import '../models/entry_model.dart';

class DislikeButton extends StatefulWidget {
  final String entryId;
  final String topicId;
  final bool isDisabled;
  final EntryModel entry;
  final Function(EntryModel) onEntryUpdated;

  const DislikeButton({
    super.key,
    required this.entryId,
    required this.topicId,
    required this.entry,
    required this.onEntryUpdated,
    this.isDisabled = false,
  });

  @override
  State<DislikeButton> createState() => _DislikeButtonState();
}

class _DislikeButtonState extends State<DislikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.red,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.isDisabled) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final entryService = Provider.of<EntryService>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    if (currentUserId == null) return;

    final isDisliked = widget.entry.isDislikedBy(currentUserId);

    if (!isDisliked) {
      await _controller.forward();
    }

    try {
      if (isDisliked) {
        entryService.undislikeEntry(widget.entryId, currentUserId);
        final updatedEntry = EntryModel(
          id: widget.entry.id,
          content: widget.entry.content,
          topicId: widget.entry.topicId,
          createdBy: widget.entry.createdBy,
          likedBy: widget.entry.likedBy,
          dislikedBy: List<String>.from(widget.entry.dislikedBy)
            ..remove(currentUserId),
          createdAt: widget.entry.createdAt,
          updatedAt: widget.entry.updatedAt,
        )..creator = widget.entry.creator;
        widget.onEntryUpdated(updatedEntry);
      } else {
        entryService.dislikeEntry(widget.entryId, currentUserId);
        final updatedEntry = EntryModel(
          id: widget.entry.id,
          content: widget.entry.content,
          topicId: widget.entry.topicId,
          createdBy: widget.entry.createdBy,
          likedBy: List<String>.from(widget.entry.likedBy)
            ..remove(currentUserId),
          dislikedBy: List<String>.from(widget.entry.dislikedBy)
            ..add(currentUserId),
          createdAt: widget.entry.createdAt,
          updatedAt: widget.entry.updatedAt,
        )..creator = widget.entry.creator;
        widget.onEntryUpdated(updatedEntry);
      }
      if (!isDisliked) {
        await _controller.reverse();
      }
    } catch (e) {
      // Revert the UI state if the operation failed
      widget.onEntryUpdated(widget.entry);
      if (!isDisliked) {
        await _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid;
    final isDisliked =
        currentUserId != null && widget.entry.isDislikedBy(currentUserId);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.thumb_down_outlined,
                  color: isDisliked ? Colors.red : _colorAnimation.value,
                ),
                onPressed: _handlePress,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.entry.dislikes}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }
}
