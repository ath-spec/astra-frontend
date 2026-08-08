import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MfCentralCasScreen extends StatefulWidget {
  final bool isOnboarding;
  const MfCentralCasScreen({super.key, this.isOnboarding = false});

  @override
  State<MfCentralCasScreen> createState() => _MfCentralCasScreenState();
}

class _MfCentralCasScreenState extends State<MfCentralCasScreen> {
  bool _selectAll = true;
  final List<bool> _amcSelections = List.generate(5, (_) => true);
  String _extentData = 'Transactions';
  String _typeData = 'Regular + Direct Investments';
  
  final List<String> _amcs = [
    'Canara Robeco\nMutual Fund',
    'Quantum Mutual\nFund',
    'HDFC Mutual\nFund',
    'Tata Mutual Fund',
    'NIPPON INDIA\nMUTUAL FUND',
  ];

  void _onSkip() {
    context.go('/');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No mutual funds added as the connection was skipped.'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onGenerateQr() {
    context.pushReplacement('/mf-fetch-loading', extra: {'isOnboarding': widget.isOnboarding});
  }

  void _toggleSelectAll(bool? value) {
    if (value != null) {
      setState(() {
        _selectAll = value;
        for (int i = 0; i < _amcSelections.length; i++) {
          _amcSelections[i] = value;
        }
      });
    }
  }

  void _toggleAmc(int index, bool? value) {
    if (value != null) {
      setState(() {
        _amcSelections[index] = value;
        _selectAll = !_amcSelections.contains(false);
      });
    }
  }

  Widget _buildDropdownCard({required String title, required String subtitle, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
              Icon(Icons.unfold_more, size: 16, color: Color(0xFF0F172A)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
                    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Builder(
          builder: (context) => SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF0F172A)),
                    ),
                  ),
                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    // Logo Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/core/images/mfcentral_logo.webp',
                          height: 72,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    
                    // Main Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Purple Header
                          Container(
                            width: double.infinity,
                            color: const Color(0xFF533B9E),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MF Central',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Secure CAS Document Processing',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Light Purple Banner inside card
                          Container(
                            width: double.infinity,
                            color: const Color(0xFFF3E8FF),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Generate QR Code for\nCAS Request',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                    height: 1.2,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'We have successfully verified that your PAN and mobile number exists in Mutual Fund Industry. Please configure your CAS preferences below.',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF334155),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Form Area
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What type of data can be shared?',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Choose the investment categories to include\n(select one)',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF64748B),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 16.h),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4.r),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _typeData,
                                          icon: Icon(Icons.unfold_more, size: 16, color: Color(0xFF0F172A)),
                                          isExpanded: true,
                                          isDense: true,
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF0F172A),
                                          ),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                _typeData = newValue;
                                              });
                                            }
                                          },
                                          items: <String>['Regular + Direct Investments', 'Regular Investments', 'Direct Investments']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 32.h),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What extent of data can be shared?',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Select the types of information you want to include',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF64748B),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 16.h),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4.r),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _extentData,
                                          icon: Icon(Icons.unfold_more, size: 16, color: Color(0xFF0F172A)),
                                          isExpanded: true,
                                          isDense: true,
                                          style: TextStyle(
                                            fontFamily: 'DMSans',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF0F172A),
                                          ),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                _extentData = newValue;
                                              });
                                            }
                                          },
                                          items: <String>['Transactions', 'Summary of Holdings']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 32.h),
                                Text(
                                  'Select the AMCs you want to include',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 16.h),
                                // Checkboxes
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: const Color(0xFFCBD5E1),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Transform.scale(
                                              scale: 0.75,
                                              child: Checkbox(
                                                value: _selectAll,
                                                onChanged: _toggleSelectAll,
                                                activeColor: const Color(0xFF533B9E),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Select All AMCs',
                                            style: TextStyle(
                                              fontFamily: 'DMSans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF533B9E),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 3.5,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 12,
                                        ),
                                        itemCount: _amcs.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: Transform.scale(
                                                  scale: 0.75,
                                                  child: Checkbox(
                                                    value: _amcSelections[index],
                                                    onChanged: (val) => _toggleAmc(index, val),
                                                    activeColor: const Color(0xFF3B82F6),
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    visualDensity: VisualDensity.compact,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _amcs[index],
                                                  style: TextStyle(
                                                    fontFamily: 'DMSans',
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF334155),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 32.h),
                                // Generate CTA
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _onGenerateQr,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF533B9E), // Dark purple
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(180, 44),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Generate QR Code',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            
            // Bottom Fixed Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    'STEP 2 OF 2',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Tap 'Generate QR code'",
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
            ),
          ),
      ),
    );
  }
}


