import 'package:flutter/material.dart';

/// A clean, custom-built table card that avoids all DataTable sizing bugs.
/// Uses a Column of rows with explicit padding — fully predictable layout.
class AstraDataCard extends StatefulWidget {
  final String? title;
  final List<String> columns;
  final List<List<String>> rows;

  const AstraDataCard({
    super.key,
    this.title,
    required this.columns,
    required this.rows,
  });

  @override
  State<AstraDataCard> createState() => _AstraDataCardState();
}

class _AstraDataCardState extends State<AstraDataCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Shell (~150ms) + staggered rows filling the rest, capped so large
      // tables don't drag the whole reveal out past the ~500ms UI ceiling.
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Row N fades/slides in on its own short window within the controller,
  /// staggered ~45ms after the previous row. Rows beyond the first several
  /// get compressed toward the end so the stagger never outruns 500ms.
  Animation<double> _rowInterval(int index) {
    final start = (0.28 + index * 0.045).clamp(0.0, 0.75);
    final end = (start + 0.22).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Shell: the bordered/shadowed frame draws in first and fast.
        final shell = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.3, curve: Cubic(0.23, 1, 0.32, 1)),
        ).value;

        return Opacity(
          opacity: shell,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - shell)),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8EDF2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Optional title bar
                    if (widget.title != null && widget.title!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(bottom: BorderSide(color: Color(0xFFE8EDF2))),
                        ),
                        child: Text(
                          widget.title!,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),

                    // Header row
                    _buildHeaderRow(),

                    // Data rows — each stripes in with its own stagger
                    ...widget.rows.asMap().entries.map((entry) {
                      final isLast = entry.key == widget.rows.length - 1;
                      final rowAnim = _rowInterval(entry.key);
                      return Opacity(
                        opacity: rowAnim.value,
                        child: Transform.translate(
                          offset: Offset(0, 6 * (1 - rowAnim.value)),
                          child: _buildDataRow(entry.value, entry.key, isLast),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8EDF2))),
      ),
      child: Row(
        children: widget.columns.asMap().entries.map((entry) {
          final isFirst = entry.key == 0;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: isFirst ? 14 : 8,
                right: 14,
                top: 10,
                bottom: 10,
              ),
              child: Text(
                entry.value,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataRow(List<String> row, int index, bool isLast) {
    final isAlt = index % 2 == 1;
    return Container(
      decoration: BoxDecoration(
        color: isAlt ? const Color(0xFFFAFBFC) : Colors.white,
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: row.asMap().entries.map((entry) {
          final isFirst = entry.key == 0;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: isFirst ? 14 : 8,
                right: 14,
                top: 11,
                bottom: 11,
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: isFirst ? FontWeight.w500 : FontWeight.w400,
                  fontSize: 13,
                  color: isFirst
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF475569),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
