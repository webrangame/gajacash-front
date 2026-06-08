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
    if (widget.mascotAssetPath != null) {
      return Image.asset(
        widget.mascotAssetPath!,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
      );
    } else if (widget.mascotNetworkUrl != null) {
      return Image.network(
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
      return Image.asset(
        'assets/images/mascot.png',
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
      );
    }
  }
}
