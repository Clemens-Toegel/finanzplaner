import 'package:flutter/material.dart';

import '../theme/pilo_brand_colors.dart';

/// Reusable BelegPilot logo with the Pilo owl mark.
///
/// Integrate anywhere in the app:
/// `const PiloLogo(size: 56)` or `const PiloLogo(size: 56, showWordmark: false)`.
class PiloLogo extends StatelessWidget {
  const PiloLogo({
    super.key,
    this.size = 56,
    this.showWordmark = true,
    this.wordmarkColor,
  });

  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;

  @override
  Widget build(BuildContext context) {
    final textColor = wordmarkColor ?? Theme.of(context).colorScheme.onSurface;

    final mark = ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: CustomPaint(painter: _PiloMarkPainter()),
    );

    if (!showWordmark) {
      return mark;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            'BelegPilot',
            style: TextStyle(
              color: textColor,
              fontSize: size * 0.36,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _PiloMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);

    // Background coin
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          PiloBrandColors.coinGradientStart,
          PiloBrandColors.coinGradientEnd,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(c, w * 0.5, bg);

    // Owl body
    final bodyPaint = Paint()
      ..color = PiloBrandColors.nightNavy.withValues(alpha: 0.93);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + h * 0.04),
        width: w * 0.68,
        height: h * 0.64,
      ),
      Radius.circular(w * 0.28),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Eyes
    final eyeOuter = Paint()..color = PiloBrandColors.cloudWhite;
    final eyeInner = Paint()..color = PiloBrandColors.nightNavy;
    final leftEye = Offset(w * 0.38, h * 0.42);
    final rightEye = Offset(w * 0.62, h * 0.42);
    canvas.drawCircle(leftEye, w * 0.11, eyeOuter);
    canvas.drawCircle(rightEye, w * 0.11, eyeOuter);
    canvas.drawCircle(leftEye, w * 0.045, eyeInner);
    canvas.drawCircle(rightEye, w * 0.045, eyeInner);

    // Scan visor over right eye
    final visor = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..color = PiloBrandColors.scanMint;
    final visorRect = Rect.fromCenter(
      center: rightEye,
      width: w * 0.27,
      height: h * 0.27,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, Radius.circular(w * 0.06)),
      visor,
    );

    // Beak
    final beak = Path()
      ..moveTo(c.dx, h * 0.50)
      ..lineTo(c.dx - w * 0.06, h * 0.57)
      ..lineTo(c.dx + w * 0.06, h * 0.57)
      ..close();
    canvas.drawPath(beak, Paint()..color = PiloBrandColors.beakAmber);

    // Receipt tab under wing
    final receiptRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.56, h * 0.60, w * 0.18, h * 0.22),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(
      receiptRect,
      Paint()..color = PiloBrandColors.cloudWhite.withValues(alpha: 0.95),
    );

    final linePaint = Paint()
      ..color = PiloBrandColors.nightNavy.withValues(alpha: 0.7)
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.59, h * 0.66),
      Offset(w * 0.71, h * 0.66),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.59, h * 0.71),
      Offset(w * 0.69, h * 0.71),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.59, h * 0.76),
      Offset(w * 0.70, h * 0.76),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PiloMarkPainter oldDelegate) => false;
}
