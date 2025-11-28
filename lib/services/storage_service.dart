import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

/// Storage service for handling file uploads to Supabase Storage
/// 
/// Handles uploads for:
/// - User avatars (profiles)
/// - Course brochures
/// - Course images
/// 
/// Follows SOLID principles - single responsibility for file storage operations.
class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  /// Storage bucket names
  static const String avatarsBucket = 'avatars';
  static const String brochuresBucket = 'brochures';
  static const String courseImagesBucket = 'course-images';

  /// Upload a user avatar
  /// 
  /// [file] - The file to upload (File for mobile, Uint8List for web)
  /// [userId] - The user ID (UUID)
  /// 
  /// Returns the public URL of the uploaded file
  Future<String> uploadAvatar({
    required dynamic file,
    required String userId,
  }) async {
    try {
      final extension = _getFileExtension(file);
      final fileName = '$userId${extension}';
      final filePath = 'avatars/$fileName';

      // Upload file
      if (kIsWeb) {
        // Web: file is Uint8List
        await _client.storage.from(avatarsBucket).uploadBinary(
              filePath,
              file is Uint8List ? file : Uint8List.fromList(file as List<int>),
              fileOptions: FileOptions(
                upsert: true,
                contentType: _getContentType(extension),
              ),
            );
      } else {
        // Mobile: file is File
        final fileData = await (file as File).readAsBytes();
        await _client.storage.from(avatarsBucket).uploadBinary(
              filePath,
              fileData,
              fileOptions: FileOptions(
                upsert: true,
                contentType: _getContentType(extension),
              ),
            );
      }

      // Get public URL
      final publicUrl = _client.storage.from(avatarsBucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Upload a course brochure (PDF)
  /// 
  /// [file] - The PDF file to upload
  /// [courseId] - The course ID (UUID)
  /// 
  /// Returns the public URL of the uploaded file
  Future<String> uploadBrochure({
    required dynamic file,
    required String courseId,
  }) async {
    try {
      final fileName = '$courseId.pdf';
      final filePath = 'brochures/$fileName';

      // Upload file
      if (kIsWeb) {
        // Web: file is Uint8List
        await _client.storage.from(brochuresBucket).uploadBinary(
              filePath,
              file is Uint8List ? file : Uint8List.fromList(file as List<int>),
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'application/pdf',
              ),
            );
      } else {
        // Mobile: file is File
        final fileData = await (file as File).readAsBytes();
        await _client.storage.from(brochuresBucket).uploadBinary(
              filePath,
              fileData,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'application/pdf',
              ),
            );
      }

      // Get public URL
      final publicUrl = _client.storage.from(brochuresBucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload brochure: $e');
    }
  }

  /// Upload a course image
  /// 
  /// [file] - The image file to upload
  /// [courseId] - The course ID (UUID)
  /// 
  /// Returns the public URL of the uploaded file
  Future<String> uploadCourseImage({
    required dynamic file,
    required String courseId,
  }) async {
    try {
      final extension = _getFileExtension(file);
      final fileName = '$courseId$extension';
      final filePath = 'images/$fileName';

      // Upload file
      if (kIsWeb) {
        // Web: file is Uint8List
        await _client.storage.from(courseImagesBucket).uploadBinary(
              filePath,
              file is Uint8List ? file : Uint8List.fromList(file as List<int>),
              fileOptions: FileOptions(
                upsert: true,
                contentType: _getContentType(extension),
              ),
            );
      } else {
        // Mobile: file is File
        final fileData = await (file as File).readAsBytes();
        await _client.storage.from(courseImagesBucket).uploadBinary(
              filePath,
              fileData,
              fileOptions: FileOptions(
                upsert: true,
                contentType: _getContentType(extension),
              ),
            );
      }

      // Get public URL
      final publicUrl = _client.storage.from(courseImagesBucket).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload course image: $e');
    }
  }

  /// Delete an avatar
  Future<void> deleteAvatar(String userId) async {
    try {
      // Try common image extensions
      final extensions = ['.jpg', '.jpeg', '.png', '.webp'];
      for (final ext in extensions) {
        final filePath = 'avatars/$userId$ext';
        try {
          await _client.storage.from(avatarsBucket).remove([filePath]);
        } catch (e) {
          // File might not exist with this extension, continue
          debugPrint('Could not delete $filePath: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }

  /// Delete a brochure
  Future<void> deleteBrochure(String courseId) async {
    try {
      final filePath = 'brochures/$courseId.pdf';
      await _client.storage.from(brochuresBucket).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete brochure: $e');
    }
  }

  /// Delete a course image
  Future<void> deleteCourseImage(String courseId) async {
    try {
      // Try common image extensions
      final extensions = ['.jpg', '.jpeg', '.png', '.webp'];
      for (final ext in extensions) {
        final filePath = 'images/$courseId$ext';
        try {
          await _client.storage.from(courseImagesBucket).remove([filePath]);
        } catch (e) {
          // File might not exist with this extension, continue
          debugPrint('Could not delete $filePath: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to delete course image: $e');
    }
  }

  /// Get file extension from file
  String _getFileExtension(dynamic file) {
    if (kIsWeb) {
      // For web, we'd need to get the extension from the file name
      // This is a simplified version - in production, you'd pass the file name
      return '.jpg'; // Default
    } else {
      // Mobile: file is File
      return path.extension((file as File).path);
    }
  }

  /// Get content type from file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  /// Get public URL for a file
  String getPublicUrl(String bucket, String filePath) {
    return _client.storage.from(bucket).getPublicUrl(filePath);
  }
}

