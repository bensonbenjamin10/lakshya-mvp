import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing favorite courses
class FavoritesProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorite_courses';
  
  Set<String> _favorites = {};
  bool _isLoading = true;

  Set<String> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_favoritesKey) ?? [];
      _favorites = favList.toSet();
    } catch (e) {
      _favorites = {};
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favorites.toList());
    } catch (e) {
      // Silent fail
    }
  }

  bool isFavorite(String courseId) {
    return _favorites.contains(courseId);
  }

  Future<void> toggleFavorite(String courseId) async {
    if (_favorites.contains(courseId)) {
      _favorites.remove(courseId);
    } else {
      _favorites.add(courseId);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> addFavorite(String courseId) async {
    if (_favorites.contains(courseId)) return;
    
    _favorites.add(courseId);
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> removeFavorite(String courseId) async {
    if (!_favorites.contains(courseId)) return;
    
    _favorites.remove(courseId);
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    notifyListeners();
    await _saveFavorites();
  }

  int get count => _favorites.length;
}

