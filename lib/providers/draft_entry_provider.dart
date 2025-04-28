import 'package:flutter/material.dart';
import '../models/draft_entry_model.dart';
import '../services/database_helper.dart';

class DraftEntryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<DraftEntryModel> _drafts = [];
  bool _isLoading = false;
  String? _error;

  List<DraftEntryModel> get drafts => _drafts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDrafts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _drafts = await _dbHelper.getAllDrafts();
      _error = null;
    } catch (e) {
      _error = 'Failed to load drafts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDraftsByTopic(String topicId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _drafts = await _dbHelper.getDraftsByTopic(topicId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load drafts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDraft(DraftEntryModel draft) async {
    try {
      await _dbHelper.createDraft(draft);
      await loadDrafts();
    } catch (e) {
      _error = 'Failed to create draft: $e';
      notifyListeners();
    }
  }

  Future<void> updateDraft(DraftEntryModel draft) async {
    try {
      await _dbHelper.updateDraft(draft);
      await loadDrafts();
    } catch (e) {
      _error = 'Failed to update draft: $e';
      notifyListeners();
    }
  }

  Future<void> deleteDraft(String id) async {
    try {
      await _dbHelper.deleteDraft(id);
      await loadDrafts();
    } catch (e) {
      _error = 'Failed to delete draft: $e';
      notifyListeners();
    }
  }

  Future<void> deleteDraftsByTopic(String topicId) async {
    try {
      await _dbHelper.deleteDraftsByTopic(topicId);
      await loadDrafts();
    } catch (e) {
      _error = 'Failed to delete drafts: $e';
      notifyListeners();
    }
  }
}
