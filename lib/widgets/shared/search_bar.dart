import 'package:flutter/material.dart';
import 'package:lakshya_mvp/theme/theme.dart';

/// Custom search bar widget with animations
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final bool showClearButton;
  final Widget? leading;
  final Widget? trailing;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.showClearButton = true,
    this.leading,
    this.trailing,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isFocused
            ? AppColors.classicBlue.withValues(alpha: 0.05)
            : AppColors.surfaceContainerLight,
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(
          color: _isFocused ? AppColors.classicBlue : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.classicBlue.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.search,
          onSubmitted: widget.onSubmitted,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral400,
                ),
            prefixIcon: widget.leading ??
                Icon(
                  Icons.search_rounded,
                  color: _isFocused ? AppColors.classicBlue : AppColors.neutral400,
                ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasText && widget.showClearButton)
                  IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.neutral500,
                    splashRadius: 20,
                  ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }
}

/// Expandable search icon that transforms into search bar
class ExpandableSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const ExpandableSearchBar({
    super.key,
    this.hintText = 'Search courses...',
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        _focusNode.requestFocus();
      } else {
        _controller.reverse();
        _textController.clear();
        widget.onChanged?.call('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _isExpanded ? 200 + (100 * _widthAnimation.value) : 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isExpanded
                ? AppColors.surfaceContainerLight
                : Colors.transparent,
            borderRadius: AppSpacing.borderRadiusFull,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _toggleSearch,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isExpanded ? Icons.close_rounded : Icons.search_rounded,
                    key: ValueKey(_isExpanded),
                    color: AppColors.neutral700,
                  ),
                ),
              ),
              if (_isExpanded)
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.neutral400,
                          ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

