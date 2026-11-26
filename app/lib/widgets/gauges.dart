import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Analog arc gauge.
class ArcGauge extends StatelessWidget {
  const ArcGauge({super.key, required this.value, required this.min, required this.max, required this.label, required this.unit});
  final double? value;
  final double min;
  final double max;
  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ArcPainter(value, min, max),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              Text(unit, style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ),
        ),
      );
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.value, this.min, this.max);
  final double? value;
  final double min, max;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2 - 10;
    final c = Offset(size.width / 2, size.height / 2 + 8);
    const start = math.pi * 0.75, sweep = math.pi * 1.5;
    final track = Paint()
      ..color = AppColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false, track);
    final v = value;
    if (v == null || max <= min) return;
    final f = ((v - min) / (max - min)).clamp(0.0, 1.0);
    final color = f > 0.9 ? AppColors.critical : (f > 0.75 ? AppColors.warning : AppColors.accent);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep * f, false, track..color = color);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.value != value || old.min != min || old.max != max;
}

/// Small line chart of recent readings.
class Sparkline extends StatelessWidget {
  const Sparkline(this.values, {super.key, this.height = 40});
  final List<double> values;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(height: height, child: CustomPaint(painter: _SparkPainter(List.of(values)), size: Size.infinite));
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.v);
  final List<double> v;
  @override
  void paint(Canvas canvas, Size size) {
    if (v.length < 2) return;
    final lo = v.reduce(math.min), hi = v.reduce(math.max);
    final span = hi - lo == 0 ? 1 : hi - lo;
    final path = Path();
    for (var i = 0; i < v.length; i++) {
      final x = i / (v.length - 1) * size.width;
      final y = size.height - (v[i] - lo) / span * (size.height - 4) - 2;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => true;
}
