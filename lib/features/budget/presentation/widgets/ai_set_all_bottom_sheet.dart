import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
enum _AllSheetState { loading, success }

class AiSetAllBottomSheet extends StatefulWidget {
  final VoidCallback onSetCompleted;

  const AiSetAllBottomSheet({super.key, required this.onSetCompleted});

  @override
  State<AiSetAllBottomSheet> createState() => _AiSetAllBottomSheetState();
}

class _AiSetAllBottomSheetState extends State<AiSetAllBottomSheet> {
  _AllSheetState _currentState = _AllSheetState.loading;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _currentState = _AllSheetState.success);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 32, bottom: 32, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: BudgetColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _currentState == _AllSheetState.loading
              ? _buildLoading()
              : _buildSuccess(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      key: const ValueKey('loadingAll'),
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: BudgetColors.black),
          const SizedBox(height: 24),
          Text("Ai is analyzing and setting all limits...",
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
      key: const ValueKey('successAll'),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: BudgetColors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 32),
        ),
        const SizedBox(height: 24),
        Text("All set!",
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: BudgetColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text("We've optimized budgets for all your categories.",
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', fontSize: 14, color: BudgetColors.grey7),
        ),
        const SizedBox(height: 32),
        ZeyroButton(eventName: 'ai_set_all_bottom_sheet_apply_tapped', 
          onPressed: () {
            widget.onSetCompleted();
            Navigator.pop(context); // Close sheet
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: BudgetColors.black,
            foregroundColor: BudgetColors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text("Done",
            style: TextStyle(fontFamily: 'DMSans', fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
