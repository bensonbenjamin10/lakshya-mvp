import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing user profiles
/// 
/// Handles creating and updating profiles after authentication
class ProfileService {
  final SupabaseClient _client;

  ProfileService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  /// Create or update a user profile after OTP verification
  /// 
  /// This is called after successful phone authentication to ensure
  /// the profile has the user's name, email, and phone from the form.
  Future<bool> upsertProfile({
    required String name,
    required String email,
    required String phone,
    String? country,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      debugPrint('ProfileService: No authenticated user');
      return false;
    }

    try {
      // Check if profile exists
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing != null) {
        // Update existing profile
        await _client.from('profiles').update({
          'full_name': name,
          if (email.isNotEmpty) 'email': email,
          'phone': phone,
          if (country != null && country.isNotEmpty) 'country': country,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
        
        debugPrint('ProfileService: Updated profile for ${user.id}');
      } else {
        // Create new profile
        await _client.from('profiles').insert({
          'id': user.id,
          'full_name': name,
          if (email.isNotEmpty) 'email': email,
          'phone': phone,
          if (country != null && country.isNotEmpty) 'country': country,
          'role': 'student',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        debugPrint('ProfileService: Created profile for ${user.id}');
      }

      // Also update auth user metadata
      await _client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
            'phone': phone,
          },
        ),
      );

      return true;
    } catch (e) {
      debugPrint('ProfileService: Error upserting profile: $e');
      return false;
    }
  }

  /// Get the current user's profile
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      return response;
    } catch (e) {
      debugPrint('ProfileService: Error fetching profile: $e');
      return null;
    }
  }

  /// Check if a profile exists for a phone number
  Future<bool> profileExistsForPhone(String phone) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      debugPrint('ProfileService: Error checking phone: $e');
      return false;
    }
  }

  /// Update profile role (e.g., from lead to student)
  Future<bool> updateRole(String role) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      await _client.from('profiles').update({
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
      
      return true;
    } catch (e) {
      debugPrint('ProfileService: Error updating role: $e');
      return false;
    }
  }
}

