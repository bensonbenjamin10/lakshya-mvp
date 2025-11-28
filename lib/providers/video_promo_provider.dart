import 'package:flutter/foundation.dart';
import 'package:lakshya_mvp/core/repositories/video_promo_repository.dart';
import 'package:lakshya_mvp/models/video_promo.dart';

/// Video Promo provider following Provider pattern
class VideoPromoProvider with ChangeNotifier {
  final VideoPromoRepository _repository;

  List<VideoPromo> _videos = [];
  bool _isLoading = false;
  String? _error;

  VideoPromoProvider(this._repository) {
    _loadVideos();
  }

  List<VideoPromo> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await _repository.getAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading videos: $e');
      notifyListeners();
    }
  }

  /// Load all videos for admin (including inactive)
  Future<void> loadAllForAdmin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await _repository.getAllForAdmin();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading videos: $e');
      notifyListeners();
    }
  }

  /// Get featured videos
  Future<List<VideoPromo>> getFeatured() async {
    try {
      return await _repository.getFeatured();
    } catch (e) {
      debugPrint('Error fetching featured videos: $e');
      return [];
    }
  }

  /// Get videos by type
  Future<List<VideoPromo>> getByType(VideoPromoType type) async {
    try {
      return await _repository.getByType(type);
    } catch (e) {
      debugPrint('Error fetching videos by type: $e');
      return [];
    }
  }

  /// Create a new video
  Future<bool> create(VideoPromo video) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdVideo = await _repository.create(video);
      _videos.add(createdVideo);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error creating video: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing video
  Future<bool> update(VideoPromo video) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedVideo = await _repository.update(video);
      final index = _videos.indexWhere((v) => v.id == video.id);
      if (index != -1) {
        _videos[index] = updatedVideo;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error updating video: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a video
  Future<bool> delete(String videoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.delete(videoId);
      _videos.removeWhere((v) => v.id == videoId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error deleting video: $e');
      notifyListeners();
      return false;
    }
  }

  /// Refresh videos list
  Future<void> refresh() async {
    await _loadVideos();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

