import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssetTodayChangeScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const AssetTodayChangeScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '';
    final subtitle = data['subtitle'] as String? ?? 'Asset';
    final value = data['value'] as String? ?? '';
    final change = data['change'] as String? ?? '';
    final isUp = data['isUp'] as bool? ?? true;
    final lastPrice = data['lastPrice'] as String? ?? '-';
    final quantity = data['quantity'] as String? ?? '-';
    
    final changeColor = isUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.sizeOf(context).width;
            
            // Constrain width on tablets
            final maxWidth = screenWidth > 600 ? 500.0 : screenWidth;
            
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Logo & Identity
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Center(
                            child: Icon(Icons.business_center_rounded, color: Color(0xFF94A3B8), size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Combined Card Block
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top Area (Grey background)
                            Container(
                              color: const Color(0xFFFAFAFA),
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                              child: Column(
                                children: [
                                  const Text(
                                    'Current Value',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    value,
                                    style: const TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'updated at 7 Aug\'26 • 3:58 pm',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Divider
                            Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                            
                            // Bottom Area (White background)
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                              child: Column(
                                children: [
                                  _buildRow('Last trading price', lastPrice),
                                  const SizedBox(height: 16),
                                  _buildDottedDivider(),
                                  const SizedBox(height: 16),
                                  
                                  _buildRow('Quantity', quantity, isValueBold: true),
                                  const SizedBox(height: 16),
                                  _buildDottedDivider(),
                                  const SizedBox(height: 16),
                                  
                                  _buildRow('1 day return', change, valueColor: changeColor, isValueBold: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color valueColor = const Color(0xFF0F172A), bool isValueBold = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            fontWeight: isValueBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDottedDivider() {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DottedLinePainter(),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var max = size.width;
    var dashWidth = 4.0;
    var dashSpace = 4.0;
    double startX = 0;

    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
