import 'package:flutter/material.dart';

class MfFundChartWidget extends StatelessWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final double height;

  const MfFundChartWidget({
    super.key,
    required this.dataPoints,
    required this.lineColor,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) return SizedBox(height: height);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _LineChartPainter(
          dataPoints: dataPoints,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;

  _LineChartPainter({
    required this.dataPoints,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final double maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    // Add some padding to top and bottom
    final double paddedMin = minVal - (range * 0.1);
    final double paddedMax = maxVal + (range * 0.1);
    final double paddedRange = paddedMax - paddedMin;

    final double stepX = size.width / (dataPoints.length - 1);

    final Path linePath = Path();
    final Path fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * stepX;
      // Invert Y axis because 0 is at the top
      final double normalizedY = (dataPoints[i] - paddedMin) / paddedRange;
      final double y = size.height - (normalizedY * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height); // Start at bottom left for fill
        fillPath.lineTo(x, y);
      } else {
        // We can use bezier curves for smoother lines, but a simple line graph matches the screenshot
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height); // End at bottom right
    fillPath.close();

    // Draw gradient fill
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.3),
          lineColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.lineColor != lineColor;
  }
}
