import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A drop-in replacement for [Image.network] that never throws or crashes.
/// Shows a shimmer placeholder while loading and a silent empty box on error.
///
/// Usage:
///   SafeNetworkImage(url: 'https://...', width: 200, fit: BoxFit.contain)
class SafeNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('SafeNetworkImage error for $url: $error');
        return errorWidget ??
            SizedBox(
              width: width,
              height: height,
              child: Center(
                child: Icon(
                  LucideIcons.image,
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  size: 32,
                ),
              ),
            );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        // Show a gentle shimmer placeholder while loading
        return SizedBox(
          width: width,
          height: height,
          child: _ShimmerBox(width: width, height: height),
        );
      },
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;

  const _ShimmerBox({this.width, this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color.lerp(
              AppColors.phoneFrameBg,
              AppColors.clayShadowColor,
              _animation.value,
            ),
          ),
        );
      },
    );
  }
}
