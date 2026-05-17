/// MK AI - Sparkline (mini fiyat grafigi)
///
/// Backend her sembolde gercek OHLCV bedava saglamadigi icin (her tile
/// icin ekstra HTTP istegi 6+ olur), her sembolun hashCode'unu seed olarak
/// kullanan deterministic bir random walk uretiriz. Sonuc gercekci ve
/// her sembol icin tutarli (her render'da ayni cizgi).
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final String symbol;
  final bool isUp;
  final Color color;
  final double width;
  final double height;
  final int points;
  final double strokeWidth;
  final bool fill;

  const Sparkline({
    super.key,
    required this.symbol,
    required this.isUp,
    required this.color,
    this.width = 70,
    this.height = 30,
    this.points = 24,
    this.strokeWidth = 1.5,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: _generateValues(symbol, isUp, points),
          color: color,
          strokeWidth: strokeWidth,
          fill: fill,
        ),
      ),
    );
  }
}

/// Sembol bazli deterministic random walk
List<double> _generateValues(String symbol, bool isUp, int n) {
  final seed = symbol.hashCode.abs();
  final rand = math.Random(seed);

  final values = <double>[];
  double current = 0.5;
  for (int i = 0; i < n; i++) {
    final delta = (rand.nextDouble() - 0.5) * 0.18;
    current += delta;
    // 0.1 - 0.9 arasinda sinirla
    current = current.clamp(0.1, 0.9);
    values.add(current);
  }

  // Son N noktayi up/down trend ile yaslayarak baslangic > son veya son > baslangic
  // ayarlamasi yap (kullanicinin gordugu "change %" ile uyumlu olsun)
  final start = values.first;
  final end = values.last;
  final shouldRise = isUp;
  final isRising = end > start;
  if (shouldRise != isRising) {
    // Sondan ilkine dogru egim degisecek sekilde yansit
    for (int i = 0; i < n; i++) {
      final t = i / (n - 1);
      values[i] = values[i] + (shouldRise ? 0.25 : -0.25) * t;
      values[i] = values[i].clamp(0.05, 0.95);
    }
  }
  return values;
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool fill;

  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    // Min/Max normalize
    final maxVal = values.reduce(math.max);
    final minVal = values.reduce(math.min);
    final range = (maxVal - minVal).abs() < 1e-6 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final dx = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final norm = (values[i] - minVal) / range;
      // Y eksenini ters cevir (yukari = pozitif)
      final y = size.height - (norm * size.height * 0.85) - size.height * 0.075;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Hafif egriyle yumusak baglanti
        final prevX = (i - 1) * dx;
        final prevNorm = (values[i - 1] - minVal) / range;
        final prevY =
            size.height - (prevNorm * size.height * 0.85) - size.height * 0.075;
        final midX = (prevX + x) / 2;
        path.cubicTo(midX, prevY, midX, y, x, y);
      }
    }

    // Cizgi
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Dolgu (gradient area)
    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.values.length != values.length ||
      oldDelegate.fill != fill;
}
