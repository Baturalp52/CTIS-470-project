import 'package:flutter/material.dart';
import '../models/entry_model.dart';
import '../models/user_model.dart';
import '../services/entry_service.dart';
import '../services/user_service.dart';

class EntryProvider extends ChangeNotifier {
  final EntryService _entryService;
  final UserService _userService;
  List<EntryModel> _entries = [];
  bool _isLoading = false;
  String? _error;

  EntryProvider(this._entryService) : _userService = UserService();

  List<EntryModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEntries(String topicId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _entryService.streamEntries(topicId: topicId).first;

      // Get unique creator IDs
      final Set<String> creatorIds =
          _entries.map((entry) => entry.createdBy).toSet();

      // Fetch all creators
      final creators = await Future.wait(
        creatorIds.map((id) => _userService.getUser(id)),
      );

      // Create a map of creator IDs to UserModel
      final Map<String, UserModel> creatorMap = {
        for (var creator in creators)
          if (creator != null) creator.id!: creator
      };

      // Set creators to entries
      for (final entry in _entries) {
        entry.creator = creatorMap[entry.createdBy];
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load entries: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEntries(String topicId) async {
    await loadEntries(topicId);
  }
}
