import 'package:lakshya_mvp/core/repositories/base_repository.dart';
import 'package:lakshya_mvp/models/video_promo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Video Promo repository following Repository Pattern
class VideoPromoRepository implements BaseRepository<VideoPromo> {
  final SupabaseClient _client;

  VideoPromoRepository(this._client);

  @override
  Future<List<VideoPromo>> getAll() async {
    try {
      final response = await _client
          .from('video_promos')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true)
          .order('created_at', ascending: false);

      return List<VideoPromo>.from(
        response.map((json) => VideoPromo.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch video promos: $e');
    }
  }

  /// Get all videos (including inactive) for admin
  Future<List<VideoPromo>> getAllForAdmin() async {
    try {
      final response = await _client
          .from('video_promos')
          .select()
          .order('display_order', ascending: true)
          .order('created_at', ascending: false);

      return List<VideoPromo>.from(
        response.map((json) => VideoPromo.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch video promos: $e');
    }
  }

  /// Get featured videos
  Future<List<VideoPromo>> getFeatured() async {
    try {
      final response = await _client
          .from('video_promos')
          .select()
          .eq('is_featured', true)
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return List<VideoPromo>.from(
        response.map((json) => VideoPromo.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch featured videos: $e');
    }
  }

  /// Get videos by type
  Future<List<VideoPromo>> getByType(VideoPromoType type) async {
    try {
      final videoPromo = VideoPromo(
        id: '',
        vimeoId: '',
        title: '',
        type: type,
      );

      final response = await _client
          .from('video_promos')
          .select()
          .eq('type', videoPromo.typeString)
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return List<VideoPromo>.from(
        response.map((json) => VideoPromo.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Failed to fetch videos by type: $e');
    }
  }

  @override
  Future<VideoPromo?> getById(String id) async {
    try {
      final response = await _client
          .from('video_promos')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return VideoPromo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch video promo: $e');
    }
  }

  @override
  Future<VideoPromo> create(VideoPromo entity) async {
    try {
      final json = entity.toJson();
      json.remove('id'); // Let database generate UUID

      final response = await _client
          .from('video_promos')
          .insert(json)
          .select()
          .single();

      return VideoPromo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create video promo: $e');
    }
  }

  @override
  Future<VideoPromo> update(VideoPromo entity) async {
    try {
      final response = await _client
          .from('video_promos')
          .update(entity.toJson())
          .eq('id', entity.id)
          .select()
          .single();

      return VideoPromo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update video promo: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      // Soft delete by setting is_active to false
      await _client
          .from('video_promos')
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete video promo: $e');
    }
  }
}

