import 'package:flutter/foundation.dart';
import '../models/topic_model.dart';
import '../services/topic_service.dart';
import '../services/auth_service.dart';

class TopicProvider with ChangeNotifier {
  final TopicService _topicService;
  final AuthService _authService;
  List<TopicModel> _topics = [];
  bool _isLoading = false;
  String? _error;

  TopicProvider(this._topicService, this._authService) {
    loadTopics();
  }

  List<TopicModel> get topics => _topics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTopics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        _error = 'User not authenticated';
        return;
      }

      _topics = await _topicService.streamTopics(createdBy: userId).first;
      _error = null;
    } catch (e) {
      _error = 'Failed to load topics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTopic(String title, String description) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        _error = 'User not authenticated';
        return false;
      }

      final topic = TopicModel(
        title: title,
        description: description,
        createdBy: userId,
      );

      await _topicService.createTopic(topic);
      await loadTopics();
      return true;
    } catch (e) {
      _error = 'Failed to create topic: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTopic(
      TopicModel topic, String title, String description) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        _error = 'User not authenticated';
        return false;
      }

      if (topic.createdBy != userId) {
        _error = 'Only the topic creator can edit this topic';
        return false;
      }

      final updatedTopic = TopicModel(
        id: topic.id,
        title: title,
        description: description,
        entryCount: topic.entryCount,
        createdBy: topic.createdBy,
        createdAt: topic.createdAt,
      );

      await _topicService.updateTopic(updatedTopic);
      await loadTopics();
      return true;
    } catch (e) {
      _error = 'Failed to update topic: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTopic(String topicId) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        _error = 'User not authenticated';
        return false;
      }

      final topic = _topics.firstWhere((t) => t.id == topicId);
      if (topic.createdBy != userId) {
        _error = 'Only the topic creator can delete this topic';
        return false;
      }

      await _topicService.delete(TopicService.collection, topicId);
      await loadTopics();
      return true;
    } catch (e) {
      _error = 'Failed to delete topic: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
