import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/category_item_model.dart';

enum _SheetState { options, manualInput, loading, success }

class CategoryBottomSheet extends StatefulWidget {
  final CategoryItem category;
  final VoidCallback onSetCompleted;

  const CategoryBottomSheet({
    super.key,
    required this.category,
    required this.onSetCompleted,
  });

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  _SheetState _currentState = _SheetState.options;
  double _manualValue = 0;

  @override
  void initState() {
    super.initState();
    _manualValue = widget.category.suggestedAmount;
  }

  void _startLoading() {
    setState(() => _currentState = _SheetState.loading);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _currentState = _SheetState.success);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: BudgetColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentState(),
        ),
      ),
    );
  }

  Widget _buildCurrentState() {
    switch (_currentState) {
      case _SheetState.options:
        return _buildOptions();
      case _SheetState.manualInput:
        return _buildManualInput();
      case _SheetState.loading:
        return _buildLoading();
      case _SheetState.success:
        return _buildSuccess();
    }
  }

  Widget _buildOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('options'),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "set budget for ${widget.category.title}",
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: BudgetColors.black,
          ),
        ),
        const SizedBox(height: 24),

        InkWell(
          onTap: _startLoading,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "let ai set limit",
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: BudgetColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "recommended: ₹${widget.category.suggestedAmount.isFinite ? widget.category.suggestedAmount.toInt() : 0}",
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 12,
                          color: BudgetColors.grey7,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: BudgetColors.grey7),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        InkWell(
          onTap: () => setState(() => _currentState = _SheetState.manualInput),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_rounded, color: BudgetColors.grey7, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "set your own limit",
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BudgetColors.black,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: BudgetColors.grey7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInput() {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('manual'),
      children: [
        ZeyroIconButton(eventName: 'category_bottom_sheet_clear_tapped', 
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: BudgetColors.black,
            size: 20,
          ),
          onPressed: () => setState(() => _currentState = _SheetState.options),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        Text(
          "how much for ${widget.category.title}?",
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: BudgetColors.black,
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            format.format(_manualValue),
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: 44,
              fontWeight: FontWeight.w600,
              color: BudgetColors.black,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: BudgetColors.black,
            inactiveTrackColor: Colors.black12,
            thumbColor: BudgetColors.white,
            trackHeight: 12,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 16,
              elevation: 4,
            ),
          ),
          child: Slider(
            value: _manualValue,
            min: 0,
            max: widget.category.suggestedAmount > 0
                ? (widget.category.suggestedAmount * 2).toDouble()
                : 1000.0,
            divisions: 50,
            onChanged: (v) => setState(() => _manualValue = v),
          ),
        ),
        const SizedBox(height: 32),
        ZeyroButton(eventName: 'category_bottom_sheet_delete_tapped', 
          onPressed: _startLoading,
          style: ElevatedButton.styleFrom(
            backgroundColor: BudgetColors.black,
            foregroundColor: BudgetColors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            "save limit",
            style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      key: const ValueKey('loading'),
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: BudgetColors.black),
          const SizedBox(height: 24),
          Text(
            "setting limit...",
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: BudgetColors.grey7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      key: const ValueKey('success'),
      children: [
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: BudgetColors.successText,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: BudgetColors.white, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          "limit set!",
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: BudgetColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${widget.category.title} budget updated successfully.",
          style: TextStyle(fontFamily: 'DMSans', fontSize: 14, color: BudgetColors.grey7),
        ),
        const SizedBox(height: 32),
        ZeyroButton(eventName: 'category_bottom_sheet_save_tapped', 
          onPressed: () {
            widget.onSetCompleted();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: BudgetColors.black,
            foregroundColor: BudgetColors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            "done",
            style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
