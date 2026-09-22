import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../data/watchlist_providers.dart';
import '../../../data/catalog_providers.dart';

/// Bookmark/watchlist toggle shown on the fund-profile screen.
///
/// [initialWatched] should come from the fund-profile response's
/// `is_watched` field so the icon starts in the correct state without an
/// extra network call. Tapping optimistically flips the icon, calls the
/// add/remove watchlist endpoint, and rolls back with a SnackBar on
/// failure. On success it invalidates [watchlistListProvider] so the
/// Watchlist screen stays in sync.
class MfBookmarkButton extends ConsumerStatefulWidget {
  final String fundId;
  final bool initialWatched;

  const MfBookmarkButton({
    super.key,
    required this.fundId,
    this.initialWatched = false,
  });

  @override
  ConsumerState<MfBookmarkButton> createState() => _MfBookmarkButtonState();
}

class _MfBookmarkButtonState extends ConsumerState<MfBookmarkButton> {
  bool _isPressed = false;
  late bool _isBookmarked;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.initialWatched;
  }

  @override
  void didUpdateWidget(covariant MfBookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The fund-profile request can resolve after this widget's first build
    // (or the fund can change), so keep in sync with the latest known state
    // as long as the user hasn't got a toggle in flight.
    if (!_isSubmitting &&
        (oldWidget.initialWatched != widget.initialWatched ||
            oldWidget.fundId != widget.fundId)) {
      _isBookmarked = widget.initialWatched;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    _toggle();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  Future<void> _toggle() async {
    if (_isSubmitting) return;

    final bool wasBookmarked = _isBookmarked;
    final bool nextBookmarked = !wasBookmarked;

    setState(() {
      _isBookmarked = nextBookmarked;
      _isSubmitting = true;
    });

    final repo = ref.read(watchlistRepositoryProvider);
    try {
      if (nextBookmarked) {
        await repo.add(widget.fundId);
      } else {
        await repo.remove(widget.fundId);
      }
      ref.invalidate(watchlistListProvider);
    } catch (e) {
      final message =
          e is ApiException ? e.message : 'Something went wrong. Please try again.';
      if (mounted) {
        setState(() => _isBookmarked = wasBookmarked);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = _isBookmarked;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isBookmarked ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              width: 1.5,
            ),
            color: isBookmarked ? const Color(0xFF0F172A) : Colors.white,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              key: ValueKey<bool>(isBookmarked),
              size: 20,
              color: isBookmarked ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }
}
