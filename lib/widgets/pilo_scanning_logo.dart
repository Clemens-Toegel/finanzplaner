import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/pilo_brand_colors.dart';

/// Animated Pilo mark for OCR scanning states.
class PiloScanningLogo extends StatefulWidget {
  const PiloScanningLogo({super.key, this.size = 64});

  final double size;

  @override
  State<PiloScanningLogo> createState() => _PiloScanningLogoState();
}

class _PiloScanningLogoState extends State<PiloScanningLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            width: widget.size,
            height: widget.size,
          ),
          child: CustomPaint(
            painter: _PiloScanningPainter(t: _controller.value),
          ),
        );
      },
    );
  }
}

class _PiloScanningPainter extends CustomPainter {
  const _PiloScanningPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);

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

    final bodyPaint = Paint()
      ..color = PiloBrandColors.nightNavy.withValues(alpha: 0.93);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + h * 0.04),
          width: w * 0.68,
          height: h * 0.64,
        ),
        Radius.circular(w * 0.28),
      ),
      bodyPaint,
    );

    final eyeOuter = Paint()..color = PiloBrandColors.cloudWhite;
    final eyeInner = Paint()..color = PiloBrandColors.nightNavy;
    final shift = math.sin(t * math.pi * 2) * (w * 0.006);
    final leftEye = Offset(w * 0.38 + shift, h * 0.42);
    final rightEye = Offset(w * 0.62 + shift, h * 0.42);
    canvas.drawCircle(leftEye, w * 0.11, eyeOuter);
    canvas.drawCircle(rightEye, w * 0.11, eyeOuter);
    canvas.drawCircle(leftEye, w * 0.045, eyeInner);
    canvas.drawCircle(rightEye, w * 0.045, eyeInner);

    final visorRect = Rect.fromCenter(
      center: rightEye,
      width: w * 0.27,
      height: h * 0.27,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visorRect, Radius.circular(w * 0.06)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..color = PiloBrandColors.scanMint.withValues(
          alpha: 0.7 + (0.3 * math.sin(t * math.pi * 2).abs()),
        ),
    );

    final scanY = visorRect.top + visorRect.height * t;
    canvas.drawLine(
      Offset(visorRect.left + w * 0.02, scanY),
      Offset(visorRect.right - w * 0.02, scanY),
      Paint()
        ..color = PiloBrandColors.scanMint
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round,
    );

    final beak = Path()
      ..moveTo(c.dx, h * 0.50)
      ..lineTo(c.dx - w * 0.06, h * 0.57)
      ..lineTo(c.dx + w * 0.06, h * 0.57)
      ..close();
    canvas.drawPath(beak, Paint()..color = PiloBrandColors.beakAmber);

    final receiptRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.56, h * 0.60, w * 0.18, h * 0.22),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(
      receiptRect,
      Paint()..color = PiloBrandColors.cloudWhite.withValues(alpha: 0.95),
    );

    final pulse = (0.08 + 0.14 * math.sin(t * math.pi * 2).abs());
    canvas.drawRRect(
      receiptRect,
      Paint()..color = PiloBrandColors.scanMint.withValues(alpha: pulse),
    );
  }

  @override
  bool shouldRepaint(covariant _PiloScanningPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
