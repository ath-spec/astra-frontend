// ============================================================
// FILE: lib/features/analytics/widgets/focus_cycle_sheet.dart
// The calendar/cycle switcher for the focus-level spend chart —
// ported from zeyro_new_ui's AnalyticsFilterSheet cycle view
// (trimmed to just cycle + custom date, no bank selector), re-skinned
// to astra's DMSans typography, colours and 4px card radius.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FocusCycleResult {
  final String cycle;
  final DateTime? fromDate;
  final DateTime? toDate;

  const FocusCycleResult({required this.cycle, this.fromDate, this.toDate});
}

class FocusCycleSheet extends StatefulWidget {
  final String currentCycle;
  final DateTime? currentFromDate;
  final DateTime? currentToDate;

  const FocusCycleSheet({
    super.key,
    required this.currentCycle,
    this.currentFromDate,
    this.currentToDate,
  });

  @override
  State<FocusCycleSheet> createState() => _FocusCycleSheetState();
}

class _FocusCycleSheetState extends State<FocusCycleSheet> {
  static const _options = ['This week', 'This month', 'This year', 'Custom'];

  late String _selectedCycle;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _selectedCycle = widget.currentCycle;
    _fromDate = widget.currentFromDate;
    _toDate = widget.currentToDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'SELECT A CYCLE',
                style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              ..._options.map(_buildOption),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(
                      FocusCycleResult(cycle: _selectedCycle, fromDate: _fromDate, toDate: _toDate),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(4)),
                    child: const Center(
                      child: Text('Done', style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String title) {
    final isSelected = _selectedCycle.toLowerCase() == title.toLowerCase();
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _selectedCycle = title),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1), width: isSelected ? 5 : 1.4),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (title == 'Custom' && isSelected) _buildCustomDatePickers(),
      ],
    );
  }

  Widget _buildCustomDatePickers() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 6, bottom: 10),
      child: Column(
        children: [
          _dateBox(
            label: 'From date',
            date: _fromDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _fromDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: _toDate ?? DateTime.now(),
              );
              if (picked != null) setState(() => _fromDate = picked);
            },
          ),
          const SizedBox(height: 10),
          _dateBox(
            label: 'To date',
            date: _toDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _toDate ?? DateTime.now(),
                firstDate: _fromDate ?? DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _toDate = picked);
            },
          ),
        ],
      ),
    );
  }

  Widget _dateBox({required String label, required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : DateFormat('MMM d, yyyy').format(date),
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: date == null ? FontWeight.w400 : FontWeight.w500, color: date == null ? const Color(0xFF94A3B8) : const Color(0xFF0F172A)),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}
