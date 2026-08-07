
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/extensions/string_extensions.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';

class PauseDateSelectionBottomSheet extends StatefulWidget {
  final Map<String, dynamic> payment;

  const PauseDateSelectionBottomSheet({super.key, required this.payment});

  @override
  State<PauseDateSelectionBottomSheet> createState() => _PauseDateSelectionBottomSheetState();
}

class _PauseDateSelectionBottomSheetState extends State<PauseDateSelectionBottomSheet> with SingleTickerProviderStateMixin {
  bool _paused = false;
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  DateTime _selectedDate = DateTime.now();
  late DateTime _initialNow;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _initialNow = DateTime(now.year, now.month, now.day);
    _selectedDate = _initialNow.add(const Duration(days: 1));
    _checkController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _onConfirmPause() async {
    setState(() {
      _paused = true;
    });
    _checkController.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context).pop(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8E7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(getProportionateScreenWidth(4)),
            topRight: Radius.circular(getProportionateScreenWidth(4)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
                children: [
                  if (!_paused) ...[
                    SizedBox(height: getProportionateScreenHeight(8)),
                    _buildServiceHero(),
                    SizedBox(height: getProportionateScreenHeight(32)),
                    Text(
                      "Select the date to pause payments until",
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(20),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(8)),
                    Text(
                      "You'll be able to resume your payments anytime",
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(13),
                        color: Colors.black.withOpacity(0.4),
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(32)),
                    _buildDatePicker(),
                    SizedBox(height: getProportionateScreenHeight(40)),
                    _buildActionButtons(context),
                  ] else
                    _buildSuccessContent(),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(20),
        getProportionateScreenHeight(16),
        getProportionateScreenWidth(20),
        getProportionateScreenHeight(8),
      ),
      child: Center(
        child: Container(
          width: getProportionateScreenWidth(40),
          height: getProportionateScreenHeight(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHero() {
    final Color bgColor = widget.payment['backgroundColor'] as Color;
    return Row(
      children: [
        Container(
          width: getProportionateScreenWidth(48),
          height: getProportionateScreenWidth(48),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
          ),
          child: Center(
            child: widget.payment['name'] == 'Netflix' 
              ? Text(
                  'N',
                  style: TextStyle(fontFamily: 'BebasNeue', 
                    color: Colors.white,
                    fontSize: getProportionateScreenWidth(24),
                    decoration: TextDecoration.none,
                  ),
                )
              : Icon(
                  widget.payment['icon'] as IconData? ?? Icons.subscriptions_rounded,
                  size: getProportionateScreenWidth(24),
                  color: Colors.white,
                ),
          ),
        ),
        SizedBox(width: getProportionateScreenWidth(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (widget.payment['name'] as String).toCapitalized(),
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(15),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                "Amount to be paid now is rs ${widget.payment['amount'].toint()}",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(11),
                  color: Colors.black.withOpacity(0.4),
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      height: getProportionateScreenHeight(180),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF1),
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
        border: Border.all(color: const Color(0xFFECEBDB)),
      ),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(fontFamily: 'DMSans', 
              fontSize: getProportionateScreenWidth(16),
              color: Colors.black,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _selectedDate,
          minimumDate: _initialNow,
          onDateTimeChanged: (date) => setState(() => _selectedDate = date),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ZeyroTapDetector(eventName: 'pause_date_selection_bottom_sheet_confirm_tapped', 
      onTap: _onConfirmPause,
      child: Container(
        width: double.infinity,
        height: getProportionateScreenHeight(48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
        ),
        child: Text(
          "Confirm pause",
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: getProportionateScreenWidth(14),
            fontWeight: FontWeight.w600,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: getProportionateScreenHeight(100)),
        ScaleTransition(
          scale: _checkAnimation,
          child: Container(
            width: getProportionateScreenWidth(72),
            height: getProportionateScreenWidth(72),
            decoration: const BoxDecoration(
              color: Color(0xFFDFF0D8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: const Color(0xFF3C763D),
              size: getProportionateScreenWidth(40),
            ),
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(24)),
        Text(
          "Auto-pay paused",
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: getProportionateScreenWidth(20),
            fontWeight: FontWeight.w600,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(12)),
        Text(
          "We've disabled autopay for ${widget.payment['name'].toCapitalized()}",
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: getProportionateScreenWidth(13),
            color: Colors.black54,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
