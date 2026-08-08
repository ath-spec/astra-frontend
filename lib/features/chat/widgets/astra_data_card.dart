import 'package:flutter/material.dart';

/// A clean, custom-built table card that avoids all DataTable sizing bugs.
/// Uses a Column of rows with explicit padding — fully predictable layout.
class AstraDataCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: const Cubic(0.23, 1, 0.32, 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
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
              if (title != null && title!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(bottom: BorderSide(color: Color(0xFFE8EDF2))),
                  ),
                  child: Text(
                    title!,
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

              // Data rows
              ...rows.asMap().entries.map((entry) {
                final isLast = entry.key == rows.length - 1;
                return _buildDataRow(entry.value, entry.key, isLast);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8EDF2))),
      ),
      child: Row(
        children: columns.asMap().entries.map((entry) {
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
