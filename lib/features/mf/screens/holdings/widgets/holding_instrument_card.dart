import 'package:flutter/material.dart';
import 'holding_item.dart';
import '../../../../../core/responsive/size_config.dart';

class HoldingInstrumentCard extends StatefulWidget {
  final HoldingDeepDiveData? data;

  const HoldingInstrumentCard({super.key, this.data});

  @override
  State<HoldingInstrumentCard> createState() => _HoldingInstrumentCardState();
}

class _HoldingInstrumentCardState extends State<HoldingInstrumentCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
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
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              child: Row(
                children: [
                  Icon(Icons.account_tree_outlined, size: getProportionateScreenWidth(16), color: const Color(0xFF64748B)),
                  SizedBox(width: getProportionateScreenWidth(12)),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Instrument Deep Dive',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: getProportionateScreenWidth(12),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          TextSpan(
                            text: ' • Role in your portfolio',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: getProportionateScreenWidth(12),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
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
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF94A3B8),
                      size: getProportionateScreenWidth(24),
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
                          padding: EdgeInsets.only(
                            left: getProportionateScreenWidth(16), 
                            right: getProportionateScreenWidth(16), 
                            bottom: getProportionateScreenHeight(20), 
                            top: 0
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(color: Color(0xFFF1F5F9), height: 1),
                              SizedBox(height: getProportionateScreenHeight(16)),
                              _buildInfoRow('PRIMARY ROLE', widget.data!.primaryRole),
                              SizedBox(height: getProportionateScreenHeight(16)),
                              _buildInfoRow('SECONDARY ROLE', widget.data!.secondaryRole),
                              SizedBox(height: getProportionateScreenHeight(16)),
                              _buildInfoRow('CONTRIBUTION TO PORTFOLIO', widget.data!.contribution),
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
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: getProportionateScreenWidth(10),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(4)),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: getProportionateScreenWidth(10),
            height: 1.4,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
