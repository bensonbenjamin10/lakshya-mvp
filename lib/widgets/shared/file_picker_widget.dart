import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/services/storage_service.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// File picker widget for uploading files to Supabase Storage
/// 
/// Supports both web and mobile platforms.
/// Handles avatar, brochure, and course image uploads.
class FilePickerWidget extends StatefulWidget {
  final String? currentUrl;
  final Function(dynamic fileData) onFileSelected;
  final FileType fileType;
  final String label;
  final String? helperText;
  final bool isRequired;

  const FilePickerWidget({
    super.key,
    this.currentUrl,
    required this.onFileSelected,
    this.fileType = FileType.image,
    this.label = 'Upload File',
    this.helperText,
    this.isRequired = false,
  });

  /// Avatar picker constructor
  const FilePickerWidget.avatar({
    super.key,
    this.currentUrl,
    required this.onFileSelected,
    this.label = 'Upload Avatar',
    this.helperText = 'Recommended: Square image, max 2MB',
    this.isRequired = false,
  }) : fileType = FileType.image;

  /// Brochure picker constructor
  const FilePickerWidget.brochure({
    super.key,
    this.currentUrl,
    required this.onFileSelected,
    this.label = 'Upload Brochure',
    this.helperText = 'PDF format only, max 10MB',
    this.isRequired = false,
  }) : fileType = FileType.custom;

  /// Course image picker constructor
  const FilePickerWidget.courseImage({
    super.key,
    this.currentUrl,
    required this.onFileSelected,
    this.label = 'Upload Course Image',
    this.helperText = 'Recommended: 16:9 aspect ratio, max 5MB',
    this.isRequired = false,
  }) : fileType = FileType.image;

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  bool _isUploading = false;
  String? _error;

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() {
        _isUploading = true;
        _error = null;
      });

      FilePickerResult? result;
      
      if (kIsWeb) {
        // Web file picker
        result = await FilePicker.platform.pickFiles(
          type: widget.fileType,
          allowedExtensions: widget.fileType == FileType.custom
              ? ['pdf']
              : ['jpg', 'jpeg', 'png', 'webp'],
        );
      } else {
        // Mobile file picker
        result = await FilePicker.platform.pickFiles(
          type: widget.fileType,
          allowedExtensions: widget.fileType == FileType.custom
              ? ['pdf']
              : null,
        );
      }

      if (result != null) {
        final file = result.files.single;
        final fileName = file.name;
        
        // Read file data
        dynamic fileData;
        if (kIsWeb) {
          if (file.bytes != null) {
            fileData = file.bytes;
          } else {
            throw Exception('Failed to read file bytes');
          }
        } else {
          if (file.path != null) {
            fileData = File(file.path!);
          } else {
            throw Exception('Failed to get file path');
          }
        }

        // Call the callback with file data
        widget.onFileSelected(fileData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File selected: $fileName'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Row(
            children: [
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.error,
                      ),
                ),
            ],
          ),
        if (widget.label.isNotEmpty) const SizedBox(height: AppSpacing.sm),

        // Current file preview or upload button
        Row(
          children: [
            // Preview or placeholder
            if (widget.currentUrl != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: ClipRRect(
                  borderRadius: AppSpacing.borderRadiusMd,
                  child: widget.fileType == FileType.custom
                      ? const Icon(Icons.picture_as_pdf, size: 40)
                      : Image.network(
                          widget.currentUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 40);
                          },
                        ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: Icon(
                  widget.fileType == FileType.custom
                      ? Icons.upload_file_rounded
                      : Icons.image_rounded,
                  size: 40,
                  color: AppColors.neutral400,
                ),
              ),

            const SizedBox(width: AppSpacing.md),

            // Upload button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadFile,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_rounded),
                label: Text(
                  widget.currentUrl != null ? 'Change File' : 'Select File',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Helper text
        if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
          ),
        ],

        // Error message
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
          ),
        ],
      ],
    );
  }
}

/// Helper widget for uploading avatar with StorageService
class AvatarUploadWidget extends StatefulWidget {
  final String? currentUrl;
  final String userId;
  final Function(String url) onUploaded;

  const AvatarUploadWidget({
    super.key,
    this.currentUrl,
    required this.userId,
    required this.onUploaded,
  });

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget> {
  bool _isUploading = false;

  Future<void> _handleFilePicked(dynamic fileData) async {
    final storageService = Provider.of<StorageService>(context, listen: false);
    
    setState(() => _isUploading = true);
    
    try {
      final url = await storageService.uploadAvatar(
        file: fileData,
        userId: widget.userId,
      );
      
      widget.onUploaded(url);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar uploaded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload avatar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FilePickerWidget.avatar(
          currentUrl: widget.currentUrl,
          onFileSelected: _handleFilePicked,
        ),
        if (_isUploading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

