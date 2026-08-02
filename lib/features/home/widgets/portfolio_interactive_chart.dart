import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class ChartDataPoint {
  final double value;
  final double mfValue;
  final double stocksValue;
  final double surplusValue;
  final String dateStr;

  const ChartDataPoint({
    required this.value, 
    this.mfValue = 0,
    this.stocksValue = 0,
    this.surplusValue = 0,
    required this.dateStr,
  });
}

class PortfolioInteractiveChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final Color lineColor;
  final double height;
  final String startDateLabel;
  final String endDateLabel;

  const PortfolioInteractiveChart({
    super.key,
    required this.data,
    this.lineColor = const Color(0xFF10B981), // Emerald 500
    this.height = 200,
    required this.startDateLabel,
    required this.endDateLabel,
  });

  @override
  State<PortfolioInteractiveChart> createState() => _PortfolioInteractiveChartState();
}

class _PortfolioInteractiveChartState extends State<PortfolioInteractiveChart> with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.data.isNotEmpty ? widget.data.length - 1 : null;
  }

  void _handleTouch(Offset localPosition, Size size) {
    if (widget.data.isEmpty) return;

    final stepX = size.width / (widget.data.length - 1);
    int closestIndex = (localPosition.dx / stepX).round().clamp(0, widget.data.length - 1);

    setState(() {
      _selectedIndex = closestIndex;
      _isExpanded = true;
    });
  }

  void _handleTouchEnd() {
    setState(() {
      _isExpanded = false;
    });
  }

  String _formatCurrency(double value) {
    return '₹${value.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Widget _buildBreakdownRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          _formatCurrency(value),
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + 40, // Extra height for axis labels
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartHeight = widget.height;
          final width = constraints.maxWidth;

          return GestureDetector(
            onPanDown: (details) => _handleTouch(details.localPosition, Size(width, chartHeight)),
            onPanUpdate: (details) => _handleTouch(details.localPosition, Size(width, chartHeight)),
            onPanEnd: (_) => _handleTouchEnd(),
            onPanCancel: () => _handleTouchEnd(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The Chart
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: chartHeight,
                  child: CustomPaint(
                    painter: _InteractiveChartPainter(
                      data: widget.data.map((e) => e.value).toList(),
                      lineColor: widget.lineColor,
                      selectedIndex: _selectedIndex,
                      isExpanded: _isExpanded,
                    ),
                  ),
                ),

                // Tooltip
                if (_selectedIndex != null)
                  Builder(
                    builder: (context) {
                      final point = widget.data[_selectedIndex!];
                      final stepX = width / (widget.data.length - 1);
                      final x = _selectedIndex! * stepX;
                      
                      // Calculate Y
                      final minVal = widget.data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
                      final maxVal = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
                      final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);
                      final paddedMin = minVal - (range * 0.1);
                      final paddedMax = maxVal + (range * 0.35); // 35% padding at top to leave room for the fixed tooltip

                      final paddedRange = paddedMax - paddedMin;
                      final normalizedY = (point.value - paddedMin) / paddedRange;
                      final y = chartHeight - (normalizedY * chartHeight);

                      // Determine tooltip position dynamically
                      final tooltipWidth = _isExpanded ? 160.0 : 145.0;
                      const arrowHeight = 6.0;
                      
                      double left = x - (tooltipWidth / 2);
                      if (left < 16) left = 16;
                      if (left + tooltipWidth > width - 16) left = width - tooltipWidth - 16;
                      
                      final arrowOffset = x - (left + tooltipWidth / 2);
                      
                      // Fixed height: tooltip bottom is always anchored 20px down from the top of the chart space
                      double bottom = chartHeight - 20;

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        left: left,
                        bottom: bottom,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: tooltipWidth,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: _TooltipShapeBorder(
                              arrowOffset: arrowOffset,
                              arrowHeight: arrowHeight,
                            ),
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          // Always apply padding to the bottom for the arrow
                          padding: const EdgeInsets.only(bottom: arrowHeight, top: 0),
                          child: AnimatedCrossFade(
                            alignment: Alignment.bottomCenter,
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            // View 1 (Simple)
                            firstChild: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    point.dateStr.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'DMMono',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(point.value),
                                    style: const TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // View 2 (Detailed Breakdown)
                            secondChild: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        point.dateStr.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: 'DMMono',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Column(
                                    children: [
                                      _buildBreakdownRow('MF:', point.mfValue),
                                      const SizedBox(height: 4),
                                      _buildBreakdownRow('STOCKS:', point.stocksValue),
                                      const SizedBox(height: 4),
                                      _buildBreakdownRow('SURPLUS:', point.surplusValue),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9), // Slate 100
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                  child: _buildBreakdownRow('TOTAL:', point.value),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Axis Labels and Tick marks
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          widget.startDateLabel,
                          style: const TextStyle(
                            fontFamily: 'DMMono',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          widget.endDateLabel,
                          style: const TextStyle(
                            fontFamily: 'DMMono',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InteractiveChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final int? selectedIndex;
  final bool isExpanded;

  _InteractiveChartPainter({
    required this.data,
    required this.lineColor,
    this.selectedIndex,
    this.isExpanded = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);
    final double paddedMin = minVal - (range * 0.1);
    final double paddedMax = maxVal + (range * 0.35); // 35% padding at top
    final double paddedRange = paddedMax - paddedMin;
    final double stepX = size.width / (data.length - 1);

    // Draw faint grid lines
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
      
    for (int i = 0; i < 7; i++) {
      final double x = size.width * (i / 6);
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, size.height), gridPaint);
      
      // Bottom tick
      canvas.drawLine(Offset(x, size.height), Offset(x, size.height + 4), Paint()..color = const Color(0xFFCBD5E1)..strokeWidth=1.5);
    }

    final Path linePath = Path();
    final Path fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double normalizedY = (data[i] - paddedMin) / paddedRange;
      final double y = size.height - (normalizedY * size.height);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill
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

    // Line
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Draw selected node
    if (selectedIndex != null) {
      final double x = selectedIndex! * stepX;
      final double normalizedY = (data[selectedIndex!] - paddedMin) / paddedRange;
      final double y = size.height - (normalizedY * size.height);

      final Paint outerNodePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
      final Paint innerNodePaint = Paint()..color = lineColor..style = PaintingStyle.fill;
      final Paint shadowPaint = Paint()..color = Colors.black.withOpacity(0.1)..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      // Calculate the true global X of the clamped tooltip arrow
      final tooltipWidth = isExpanded ? 160.0 : 145.0;
      double left = x - (tooltipWidth / 2);
      if (left < 16) left = 16;
      if (left + tooltipWidth > size.width - 16) left = size.width - tooltipWidth - 16;
      
      double arrowCenter = x - left;
      // Clamping logic from _TooltipShapeBorder (radius = 4, arrowWidth = 10)
      final minArrowCenter = 4.0 + 5.0;
      final maxArrowCenter = tooltipWidth - 4.0 - 5.0;
      arrowCenter = arrowCenter.clamp(minArrowCenter, maxArrowCenter);
      final globalArrowX = left + arrowCenter;

      // Draw solid black stem line connecting the true clamped arrow tip to the data point
      final Paint stemPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      // The tip of the tooltip is at y = 20
      if (y > 20) {
        final path = Path()
          ..moveTo(globalArrowX, 20)
          ..lineTo(globalArrowX, 28) // Straight down from the arrow
          ..lineTo(x, 38)            // Angled kink to the vertical line
          ..lineTo(x, y);            // Straight down to the node
        canvas.drawPath(path, stemPaint);
      }

      canvas.drawCircle(Offset(x, y), 6, shadowPaint);
      canvas.drawCircle(Offset(x, y), 6, outerNodePaint);
      canvas.drawCircle(Offset(x, y), 3, innerNodePaint);
    }
  }
  
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double dy = p2.dy - p1.dy;
    double startY = p1.dy;
    while (startY < p2.dy) {
      canvas.drawLine(Offset(p1.dx, startY), Offset(p1.dx, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveChartPainter oldDelegate) {
    return oldDelegate.data != data || 
           oldDelegate.lineColor != lineColor || 
           oldDelegate.selectedIndex != selectedIndex ||
           oldDelegate.isExpanded != isExpanded;
  }
}

class _TooltipShapeBorder extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final double arrowOffset;

  const _TooltipShapeBorder({
    this.arrowWidth = 10.0,
    this.arrowHeight = 6.0,
    this.radius = 4.0,
    this.borderColor = const Color(0xFF475569), // Slate 600
    this.borderWidth = 1.5,
    this.arrowOffset = 0.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight - Offset(0, arrowHeight));
    
    double arrowCenter = rect.center.dx + arrowOffset;
    arrowCenter = arrowCenter.clamp(rect.left + radius + arrowWidth / 2, rect.right - radius - arrowWidth / 2);

    final path = Path();
    path
      ..moveTo(rect.left + radius, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + radius), radius: Radius.circular(radius))
      ..lineTo(rect.right, rect.bottom - radius)
      ..arcToPoint(Offset(rect.right - radius, rect.bottom), radius: Radius.circular(radius))
      ..lineTo(arrowCenter + arrowWidth / 2, rect.bottom)
      ..lineTo(arrowCenter, rect.bottom + arrowHeight)
      ..lineTo(arrowCenter - arrowWidth / 2, rect.bottom)
      ..lineTo(rect.left + radius, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - radius), radius: Radius.circular(radius))
      ..lineTo(rect.left, rect.top + radius)
      ..arcToPoint(Offset(rect.left + radius, rect.top), radius: Radius.circular(radius))
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = borderWidth;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}

