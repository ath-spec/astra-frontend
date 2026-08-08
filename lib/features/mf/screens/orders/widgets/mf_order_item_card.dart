import 'package:flutter/material.dart';

class MfOrderItemCard extends StatelessWidget {
  final String logoText;
  final Color logoColor;
  final String fundName;
  final String amount;
  final String type;
  final String status;
  final bool isLast;

  const MfOrderItemCard({
    super.key,
    required this.logoText,
    required this.logoColor,
    required this.fundName,
    required this.amount,
    required this.type,
    required this.status,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EXTERNAL tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'EXTERNAL',
              style: TextStyle(
                fontFamily: 'DMSANS',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  logoText,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: logoColor,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              // Fund Name & Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fundName,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              // Amount & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981), // Emerald 500 for COMPLETED
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isLast)
            Row(
              children: List.generate(
                60,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index % 2 == 0 ? const Color(0xFFE2E8F0) : Colors.transparent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
