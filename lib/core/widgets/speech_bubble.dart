import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';

class SpeechBubble extends StatefulWidget {
  final String? text;
  final List<String>? texts;
  final Duration interval;

  const SpeechBubble({
    super.key,
    this.text,
    this.texts,
    this.interval = const Duration(seconds: 5),
  }) : assert(text != null || texts != null, 'Either text or texts must be provided');

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble> {
  late List<String> _messages;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initMessages();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.texts != widget.texts) {
      _timer?.cancel();
      _initMessages();
      _currentIndex = 0;
      _startTimer();
    }
  }

  void _initMessages() {
    if (widget.texts != null) {
      _messages = widget.texts!;
    } else if (widget.text != null) {
      _messages = [widget.text!];
    } else {
      _messages = [];
    }
  }

  void _startTimer() {
    if (_messages.length > 1) {
      _timer = Timer.periodic(widget.interval, (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _messages.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String displayText = _messages.isNotEmpty ? _messages[_currentIndex] : '';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.clayShadowColor,
                offset: Offset(8, 8),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-8, -8),
                blurRadius: 16,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              displayText,
              key: ValueKey<String>(displayText),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryGreen,
                height: 1.3,
              ),
            ),
          ),
        ),
        // Triangle for speech bubble tail
        CustomPaint(
          size: const Size(24, 12),
          painter: _TrianglePainter(color: AppColors.background),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
