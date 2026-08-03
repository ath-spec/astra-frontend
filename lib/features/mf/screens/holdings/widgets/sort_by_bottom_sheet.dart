import 'package:flutter/material.dart';

enum SortOption {
  currentValue,
  returns,
  xirr,
  oneDayChange,
  alphabetically,
}

class SortByBottomSheet extends StatefulWidget {
  final SortOption? currentSort;

  const SortByBottomSheet({super.key, this.currentSort});

  @override
  State<SortByBottomSheet> createState() => _SortByBottomSheetState();
}

class _SortByBottomSheetState extends State<SortByBottomSheet> {
  SortOption? _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
  }

  void _onApply() {
    Navigator.pop(context, {'applied': true, 'sort': _selectedSort});
  }

  void _onReset() {
    setState(() {
      _selectedSort = null;
    });
  }

  Widget _buildRadioOption(String title, SortOption option, double scale) {
    bool isSelected = _selectedSort == option;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSort = option;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0 * scale),
        child: Row(
          children: [
            Container(
              width: 10 * scale,
              height: 10 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                  width: isSelected ? 6 * scale : 1.5 * scale,
                ),
              ),
            ),
            SizedBox(width: 12 * scale),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Clamp the scale to 1.0 maximum so it doesn't get overly huge on very large screens
    final double scale = (MediaQuery.sizeOf(context).width / 375.0).clamp(0.5, 1.0);

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill
            Container(
              width: 40 * scale,
              height: 4 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
            SizedBox(height: 24 * scale),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5 * scale,
                  ),
                ),
                GestureDetector(
                  onTap: _onReset,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Divider(color: const Color(0xFFF1F5F9), height: 1 * scale),
            SizedBox(height: 8 * scale),

            // Options
            _buildRadioOption('Current Value', SortOption.currentValue, scale),
            Divider(color: const Color(0xFFF1F5F9), height: 1 * scale),
            _buildRadioOption('Returns', SortOption.returns, scale),
            Divider(color: const Color(0xFFF1F5F9), height: 1 * scale),
            _buildRadioOption('XIRR', SortOption.xirr, scale),
            Divider(color: const Color(0xFFF1F5F9), height: 1 * scale),
            _buildRadioOption('1-Day Change', SortOption.oneDayChange, scale),
            Divider(color: const Color(0xFFF1F5F9), height: 1 * scale),
            _buildRadioOption('Alphabetically', SortOption.alphabetically, scale),
            
            SizedBox(height: 24 * scale),

            // Apply Button
            GestureDetector(
              onTap: _onApply,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16 * scale),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4 * scale),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF333333), Color(0xFF000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
                ),
                child: Text(
                  'Apply',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

