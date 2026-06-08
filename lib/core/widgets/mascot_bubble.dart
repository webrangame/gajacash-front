import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';

class MascotBubble extends StatefulWidget {
  final List<String> messages;
  final String? mascotAssetPath;
  final String? mascotNetworkUrl;
  final double mascotWidth;
  final Duration rotationInterval;

  const MascotBubble({
    super.key,
    required this.messages,
    this.mascotAssetPath,
    this.mascotNetworkUrl,
    this.mascotWidth = 200,
    this.rotationInterval = const Duration(seconds: 5),
  });

  // Constructor convenience for a single message
  MascotBubble.single({
    super.key,
    required String message,
    this.mascotAssetPath,
    this.mascotNetworkUrl,
    this.mascotWidth = 200,
  }) : messages = [message],
       rotationInterval = const Duration(seconds: 5);

  @override
  State<MascotBubble> createState() => _MascotBubbleState();
}

class _MascotBubbleState extends State<MascotBubble> {
  int _currentMessageIndex = 0;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    if (widget.messages.length > 1) {
      _rotationTimer = Timer.periodic(widget.rotationInterval, (timer) {
        if (mounted) {
          setState(() {
            _currentMessageIndex =
                (_currentMessageIndex + 1) % widget.messages.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Speech Bubble
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Main bubble container
            Container(
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: context.neumorphic.clayShadow,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    widget.messages[_currentMessageIndex],
                    key: ValueKey<int>(_currentMessageIndex),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
            // Tail triangle at bottom center
            Positioned(
              bottom: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.clayShadowColor.withValues(alpha: 0.5),
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Overlay to hide top edge of tail
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 30,
                  height: 10,
                  color: theme.scaffoldBackgroundColor,
                ),
              ),
            ),
          ],
        ),
        // Mascot (takes up the remaining space)
        _buildMascotImage(),
      ],
    );
  }

  Widget _buildMascotImage() {
    Widget image;
    if (widget.mascotAssetPath != null) {
      image = Image.asset(
        widget.mascotAssetPath!,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
      );
    } else if (widget.mascotNetworkUrl != null) {
      image = Image.network(
        widget.mascotNetworkUrl!,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.image_not_supported,
          size: widget.mascotWidth,
          color: AppColors.primaryGreen,
        ),
      );
    } else {
      // Fallback default local mascot
      image = Image.asset(
        'assets/images/mascot.png',
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
      );
    }
    return Expanded(child: image);
  }
}
