import 'package:flutter/material.dart';

class MfInstrumentCard extends StatefulWidget {
  final String instrumentType;
  final String primaryRole;
  final String secondaryRole;
  final String strengths;
  final String tradeOffs;

  const MfInstrumentCard({
    super.key,
    this.instrumentType = 'Mutual Fund',
    required this.primaryRole,
    required this.secondaryRole,
    required this.strengths,
    required this.tradeOffs,
  });

  @override
  State<MfInstrumentCard> createState() => _MfInstrumentCardState();
}

class _MfInstrumentCardState extends State<MfInstrumentCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.account_tree_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Instrument Deep Dive',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextSpan(
                            text: ' • ${widget.instrumentType}',
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Expandable Content
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: const Cubic(0.23, 1, 0.32, 1),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                child: _isExpanded 
                    ? AnimatedOpacity(
                        opacity: _isExpanded ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0, top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(color: Color(0xFFF1F5F9), height: 1),
                              const SizedBox(height: 16),
                              _buildInfoRow('PRIMARY ROLE', widget.primaryRole),
                              const SizedBox(height: 16),
                              _buildInfoRow('SECONDARY ROLE', widget.secondaryRole),
                              const SizedBox(height: 16),
                              _buildInfoRow('STRENGTHS', widget.strengths),
                              const SizedBox(height: 16),
                              _buildInfoRow('TRADE-OFFS', widget.tradeOffs),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            height: 1.4,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
