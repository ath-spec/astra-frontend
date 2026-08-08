import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  Widget _buildRadioOption(String title, SortOption option) {
    bool isSelected = _selectedSort == option;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSort = option;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12.sp,
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
        return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 24.h),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: _onReset,
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: const Color(0xFFF1F5F9), height: 1.h),
            SizedBox(height: 8.h),

            // Options
            _buildRadioOption('Current Value', SortOption.currentValue),
            Divider(color: const Color(0xFFF1F5F9), height: 1.h),
            _buildRadioOption('Returns', SortOption.returns),
            Divider(color: const Color(0xFFF1F5F9), height: 1.h),
            _buildRadioOption('XIRR', SortOption.xirr),
            Divider(color: const Color(0xFFF1F5F9), height: 1.h),
            _buildRadioOption('1-Day Change', SortOption.oneDayChange),
            Divider(color: const Color(0xFFF1F5F9), height: 1.h),
            _buildRadioOption('Alphabetically', SortOption.alphabetically),
            
            SizedBox(height: 24.h),

            // Apply Button
            GestureDetector(
              onTap: _onApply,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF333333), Color(0xFF000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Apply',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14.sp,
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

