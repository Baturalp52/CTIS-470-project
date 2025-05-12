import 'package:flutter/material.dart';
import '../models/entry_model.dart';
import '../widgets/entry_card.dart';
import '../providers/entry_provider.dart';
import 'package:provider/provider.dart';

class LikedEntriesTab extends StatefulWidget {
  final String userId;

  const LikedEntriesTab({
    super.key,
    required this.userId,
  });

  @override
  State<LikedEntriesTab> createState() => _LikedEntriesTabState();
}

class _LikedEntriesTabState extends State<LikedEntriesTab> {
  List<EntryModel> _entries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      final entries = await entryProvider.getLikedEntries(widget.userId);
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load entries: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No liked entries found'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        return EntryCard(entry: _entries[index]);
      },
    );
  }
}
