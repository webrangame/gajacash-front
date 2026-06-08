import 'package:flutter/material.dart';

class InsetNeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double height;
  final double borderRadius;
  final Color color;
  final bool isFocused;

  const InsetNeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height = 56,
    this.borderRadius = 20,
    this.color = const Color(0xFFE8F4ED),
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isFocused ? const Color(0xFF006633).withValues(alpha: 0.25) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // Render the high-fidelity 3D inner shadows
          Positioned.fill(
            child: CustomPaint(
              painter: _InsetShadowPainter(
                borderRadius: borderRadius - (isFocused ? 1.2 : 0.0),
                blurRadius: 8.0, // Thicker, softer 3D blur
                darkOffset: const Offset(4, 4), // 4px top-left cast
                lightOffset: const Offset(-4, -4), // 4px bottom-right cast
                darkShadowColor: const Color(0xFFC5D1CB),
                lightShadowColor: Colors.white,
              ),
            ),
          ),
          
          // Content child
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InsetShadowPainter extends CustomPainter {
  final double borderRadius;
  final Color darkShadowColor;
  final Color lightShadowColor;
  final Offset darkOffset;
  final Offset lightOffset;
  final double blurRadius;

  _InsetShadowPainter({
    required this.borderRadius,
    this.darkShadowColor = const Color(0xFFC5D1CB),
    this.lightShadowColor = Colors.white,
    this.darkOffset = const Offset(3, 3),
    this.lightOffset = const Offset(-3, -3),
    this.blurRadius = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Save and clip to the RRect area to draw the shadow inward only
    canvas.save();
    canvas.clipRRect(rrect);

    final Path outerPath = Path()..addRect(rect.inflate(blurRadius + 20));
    final Path innerPath = Path()..addRRect(rrect);
    final Path differencePath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    // Draw dark shadow (cast from top-left)
    final darkPaint = Paint()
      ..color = darkShadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
    canvas.save();
    canvas.translate(darkOffset.dx, darkOffset.dy);
    canvas.drawPath(differencePath, darkPaint);
    canvas.restore();

    // Draw light shadow (cast from bottom-right)
    final lightPaint = Paint()
      ..color = lightShadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
    canvas.save();
    canvas.translate(lightOffset.dx, lightOffset.dy);
    canvas.drawPath(differencePath, lightPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InsetShadowPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.darkShadowColor != darkShadowColor ||
        oldDelegate.lightShadowColor != lightShadowColor ||
        oldDelegate.darkOffset != darkOffset ||
        oldDelegate.lightOffset != lightOffset ||
        oldDelegate.blurRadius != blurRadius;
  }
}
