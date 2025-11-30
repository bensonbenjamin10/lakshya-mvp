import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Beautiful in-app Markdown content reader
/// 
/// Features:
/// - Native rendering with custom styling
/// - Progress tracking via scroll position
/// - Link handling
/// - Code block styling
/// - Image support
class MarkdownContentWidget extends StatefulWidget {
  final String content;
  final String? title;
  final VoidCallback? onComplete;
  final Function(double)? onScrollProgress;

  const MarkdownContentWidget({
    super.key,
    required this.content,
    this.title,
    this.onComplete,
    this.onScrollProgress,
  });

  @override
  State<MarkdownContentWidget> createState() => _MarkdownContentWidgetState();
}

class _MarkdownContentWidgetState extends State<MarkdownContentWidget> {
  final ScrollController _scrollController = ScrollController();
  double _readingProgress = 0;
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (maxScroll > 0) {
      final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      setState(() {
        _readingProgress = progress;
      });
      
      widget.onScrollProgress?.call(progress);
      
      // Mark as complete when user reaches 90% or more
      if (progress >= 0.9 && !_hasReachedEnd) {
        _hasReachedEnd = true;
        widget.onComplete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reading progress indicator
        _buildProgressBar(),
        
        // Markdown content
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppSpacing.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppSpacing.borderRadiusLg,
              child: Markdown(
                controller: _scrollController,
                data: widget.content,
                selectable: true,
                padding: const EdgeInsets.all(AppSpacing.xl),
                styleSheet: _buildMarkdownStyle(context),
                onTapLink: (text, href, title) => _handleLink(href),
                imageBuilder: (uri, title, alt) => _buildImage(uri),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reading Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral500,
                ),
              ),
              Text(
                '${(_readingProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _readingProgress >= 0.9 
                      ? AppColors.success 
                      : AppColors.classicBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _readingProgress,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _readingProgress >= 0.9 
                    ? AppColors.success 
                    : AppColors.classicBlue,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyle(BuildContext context) {
    final theme = Theme.of(context);
    
    return MarkdownStyleSheet(
      // Headings
      h1: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.neutral900,
        height: 1.3,
      ),
      h2: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.neutral800,
        height: 1.3,
      ),
      h3: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.neutral800,
        height: 1.4,
      ),
      h4: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.neutral700,
      ),
      
      // Body text
      p: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.neutral700,
        height: 1.7,
        letterSpacing: 0.2,
      ),
      
      // Lists
      listBullet: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.classicBlue,
      ),
      
      // Blockquote
      blockquote: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.neutral600,
        fontStyle: FontStyle.italic,
        height: 1.6,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.classicBlue.withValues(alpha: 0.5),
            width: 4,
          ),
        ),
        color: AppColors.classicBlue.withValues(alpha: 0.05),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      
      // Code
      code: TextStyle(
        fontFamily: 'monospace',
        backgroundColor: AppColors.neutral100,
        color: AppColors.vivaMagenta,
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      codeblockPadding: const EdgeInsets.all(AppSpacing.md),
      
      // Links
      a: TextStyle(
        color: AppColors.classicBlue,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.classicBlue.withValues(alpha: 0.5),
      ),
      
      // Table
      tableHead: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.neutral800,
      ),
      tableBody: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.neutral700,
      ),
      tableBorder: TableBorder.all(
        color: AppColors.neutral200,
        width: 1,
      ),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.all(AppSpacing.sm),
      
      // Horizontal rule
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      
      // Spacing
      h1Padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      h2Padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      h3Padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      pPadding: const EdgeInsets.only(bottom: AppSpacing.md),
      listIndent: 24,
    );
  }

  Widget _buildImage(Uri uri) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderRadiusMd,
        child: Image.network(
          uri.toString(),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 200,
              color: AppColors.neutral100,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: AppColors.classicBlue,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) {
            return Container(
              height: 120,
              color: AppColors.neutral100,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_not_supported, color: AppColors.neutral400),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Image unavailable',
                      style: TextStyle(color: AppColors.neutral500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleLink(String? href) async {
    if (href == null) return;
    
    final uri = Uri.tryParse(href);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

