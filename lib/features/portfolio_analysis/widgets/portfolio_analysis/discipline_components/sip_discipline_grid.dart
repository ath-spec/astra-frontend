import 'package:flutter/material.dart';
import 'generic_info_sheet.dart';
import 'sip_month_sheet.dart';

class SipDisciplineGrid extends StatelessWidget {
  const SipDisciplineGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'SIP Discipline',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const GenericInfoSheet(
                      title: 'What is SIP Discipline?',
                      paragraphs: [
                        'SIP Discipline measures how reliably you complete your scheduled SIP instalments.',
                        'It looks at the proportion of SIPs that were successfully executed during the period. Higher reliability reflects stronger follow-through on planned investments.',
                      ],
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '0 of 0',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -1.0,
                  ),
                ),
                TextSpan(
                  text: ' SIP instalments completed',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Measures how reliably you complete your\nscheduled SIP instalments.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Streak pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.local_fire_department, size: 16, color: Color(0xFF3182CE)),
                SizedBox(width: 8),
                Text(
                  '0 MONTH STREAK',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF56565),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // 2x6 Grid
          _buildMonthGrid(context),
          const SizedBox(height: 32),
          // Bottom Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // Light orange
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFFBD38D)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F172A)),
                  ),
                  child: const Center(
                    child: Icon(Icons.bolt, size: 14, color: Color(0xFFD69E2E)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Some SIPs placed through other apps may not be\nvisible here.',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMonthCircle(context, 'SEP', false, false),
            _buildMonthCircle(context, 'OCT', false, false),
            _buildMonthCircle(context, 'NOV', false, false),
            _buildMonthCircle(context, 'DEC', false, false),
            _buildMonthCircle(context, 'JAN', false, false),
            _buildMonthCircle(context, 'FEB', false, false),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMonthCircle(context, 'MAR', false, false),
            _buildMonthCircle(context, 'APR', false, false),
            _buildMonthCircle(context, 'MAY', false, false),
            _buildMonthCircle(context, 'JUN', false, false),
            _buildMonthCircle(context, 'JUL', false, false),
            _buildMonthCircle(context, 'AUG', true, true),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthCircle(BuildContext context, String month, bool isActive, bool isCheck) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => SipMonthSheet(initialMonth: month),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: isActive 
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                : const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            decoration: isActive 
                ? BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            child: Text(
              month,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isActive ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: Center(
              child: Icon(
                isActive || isCheck ? Icons.check : Icons.close,
                size: 14,
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
