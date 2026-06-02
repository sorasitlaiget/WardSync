import 'dart:math';
import 'package:flutter/material.dart';

/// WardSync hexagon logo with medical cross and 4 triage-color dots.
/// Matches the Figma design: flat-top hexagon, cross inside,
/// RED(top-left), ORANGE(top-right), GREEN(bottom-right), GRAY(bottom-left).
class WardSyncLogo extends StatelessWidget {
  final double size;

  const WardSyncLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexLogoPainter(),
      ),
    );
  }
}

class _HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Slightly smaller radius so dots don't clip
    final r = size.width * 0.42;

    // ── Flat-top hexagon vertices ──────────────────────────────────────────
    // Angle 0° = right side, going counter-clockwise gives:
    //   0°   → right        (no dot)
    //   60°  → top-right    (ORANGE)
    //   120° → top-left     (RED)
    //   180° → left         (no dot)
    //   240° → bottom-left  (GRAY)
    //   300° → bottom-right (GREEN)
    List<Offset> verts = List.generate(6, (i) {
      final a = (60 * i) * pi / 180;
      return Offset(cx + r * cos(a), cy - r * sin(a));
    });

    // ── Draw hexagon stroke ────────────────────────────────────────────────
    final hexPaint = Paint()
      ..color = const Color(0xFF7A9E1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final hexPath = Path()..moveTo(verts[0].dx, verts[0].dy);
    for (var v in verts.skip(1)) {
      hexPath.lineTo(v.dx, v.dy);
    }
    hexPath.close();
    canvas.drawPath(hexPath, hexPaint);

    // ── Draw medical cross ─────────────────────────────────────────────────
    final crossColor = const Color(0xFF6B8E14);
    final armW = r * 0.32;
    final armL = r * 0.72;
    final crossPaint = Paint()
      ..color = crossColor
      ..style = PaintingStyle.fill;

    // Horizontal arm
    final hRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy), width: armL, height: armW),
      Radius.circular(armW * 0.2),
    );
    // Vertical arm
    final vRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cy), width: armW, height: armL),
      Radius.circular(armW * 0.2),
    );
    canvas.drawRRect(hRect, crossPaint);
    canvas.drawRRect(vRect, crossPaint);

    // ── Draw 4 triage-color dots ───────────────────────────────────────────
    final dotR = size.width * 0.075;
    final dots = [
      // (vertex index, color, outline)
      (1, const Color(0xFFFF9900), const Color(0xFFCC7700)), // top-right → ORANGE
      (2, const Color(0xFFFF3333), const Color(0xFFCC1100)), // top-left  → RED
      (4, const Color(0xFF888888), const Color(0xFF555555)), // bottom-left → GRAY
      (5, const Color(0xFF33CC55), const Color(0xFF119933)), // bottom-right → GREEN
    ];

    for (final (idx, fill, stroke) in dots) {
      final pos = verts[idx];
      canvas.drawCircle(
        pos,
        dotR + 1.2,
        Paint()..color = stroke,
      );
      canvas.drawCircle(
        pos,
        dotR,
        Paint()..color = fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
