import 'package:flutter/material.dart';

class FoliosBottomSheet extends StatelessWidget {
  const FoliosBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final s = screenWidth / 375.0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12 * s),
          Center(
            child: Container(
              width: 40 * s,
              height: 4 * s,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2 * s),
              ),
            ),
          ),
          SizedBox(height: 24 * s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Folios',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8 * s),
                Text(
                  '1 folio',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10 * s,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(height: 24 * s),
                _buildDashedDivider(s),
                SizedBox(height: 24 * s),
                Text(
                  '₹2,36,538.56',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8 * s),
                Row(
                  children: [
                    Text(
                      'Folio no. 17762024046',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10 * s,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2 * s),
                      ),
                      child: Text(
                        'EXTERNAL',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48 * s), // bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider(double s) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 4.0 * s;
        final dashHeight = 1.0 * s;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9)),
              ),
            );
          }),
        );
      },
    );
  }
}
