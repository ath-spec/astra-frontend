import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/budget/data/models/budget_api_models.dart';
import 'package:astra_frontend/services/finance_repository.dart';
import 'package:astra_frontend/services/service_providers.dart';
import 'package:astra_frontend/core/network/error_handler.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/set_category_bottom_sheet.dart';
import 'package:astra_frontend/features/budget/presentation/widgets/budget_conflict_bottom_sheet.dart';
import 'package:astra_frontend/services/analytics_service.dart';
import 'package:go_router/go_router.dart';

class BudgetSettingsScreen extends ConsumerStatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  ConsumerState<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends ConsumerState<BudgetSettingsScreen> {
  BudgetSettingsResponse? _settings;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  late final TextEditingController _incomeController;
  late final TextEditingController _limitController;

  final _nf = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  bool get _hasChanges {
    if (_settings == null) return false;
    final currentIncome = double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0.0;
    final currentLimit = double.tryParse(_limitController.text.replaceAll(',', '')) ?? 0.0;
    return currentIncome != _settings!.linkedIncome || currentLimit != _settings!.spendingLimit;
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('budget_settings_screen');
    _incomeController = TextEditingController();
    _limitController = TextEditingController();
    _incomeController.addListener(_onInputChanged);
    _limitController.addListener(_onInputChanged);
    _fetchSettings();
    
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none) && mounted) {
        // Clear the initial-load error banner and re-fetch if settings never loaded.
        if (_error != null && _settings == null) {
          setState(() => _error = null);
          _fetchSettings();
        }
      }
    });
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _incomeController.removeListener(_onInputChanged);
    _limitController.removeListener(_onInputChanged);
    _incomeController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
         if (mounted) setState(() { _isLoading = false; _error = "No DMSansnet connection. Please connect and try again."; });
         return;
      }
      final settings = await ref.read(budgetStateProvider).fetchSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _incomeController.text = settings.linkedIncome.toStringAsFixed(0);
          _limitController.text = settings.spendingLimit.toStringAsFixed(0);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }


  Future<void> _saveSettings() async {
    if (_isSaving) return; // Spam protection
    
    FocusManager.instance.primaryFocus?.unfocus();
    final income = double.tryParse(_incomeController.text.replaceAll(',', ''));
    final limit = double.tryParse(_limitController.text.replaceAll(',', ''));
    if (income == null || limit == null) return;
    
    setState(() {
      _isSaving = true;
    });

    if (limit > 99999999.0) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppErrorHandler.show(context, null, fallback: 'Maximum total budget is \u20b99,99,99,999');
      }
      return;
    }

    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppErrorHandler.show(context, 'offline', fallback: 'No internet connection. Please connect and try again.');
      }
      return;
    }

    try {
      final budgetState = ref.read(budgetStateProvider);
      final oldLimit = _settings?.spendingLimit;

      // 1. Test the limit against the ML engine first!
      budgetState.suggestedCategories = [];
      await budgetState.fetchCategorySuggestions(limit); // Throws BudgetConflictException if rejected

      // 2. If we reach here, the ML engine approved it. Safe to update the DB!
      await FinanceRepository(dioApiClient).updateBudgetSettings(
        spendingLimit: limit,
        linkedIncome: income,
      );
      await budgetState.fetchSettings(forceRefresh: true);
      
      if (budgetState.currentSessionId == null || budgetState.currentSessionId!.isEmpty) {
        final now = DateTime.now();
        final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        await budgetState.createSession(limit, month: month);
      } else {
        await FinanceRepository(dioApiClient).updateBudgetSession(
          sessionId: budgetState.currentSessionId!,
          totalBudget: limit,
        );
      }

      if (mounted) {
        // Show bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => SetCategoryBottomSheet(
            totalBudget: limit,
            oldBudgetLimit: oldLimit,
          ),
        ).then((value) async {
          if (value == null && oldLimit != null && mounted) {
            try {
              await FinanceRepository(dioApiClient).updateBudgetSettings(
                spendingLimit: oldLimit,
              );
              await ref.read(budgetStateProvider).fetchSettings(forceRefresh: true);
              if (budgetState.currentSessionId != null && budgetState.currentSessionId!.isNotEmpty) {
                await FinanceRepository(dioApiClient).updateBudgetSession(
                  sessionId: budgetState.currentSessionId!,
                  totalBudget: oldLimit,
                );
              }
            } catch (_) {}
          }
          if (mounted) {
             _fetchSettings(); // Refresh to old values if reverted, or new values if saved
          }
        });
      }
    } on BudgetConflictException catch (e) {
      if (mounted) {
        if (_settings != null) {
          _incomeController.text = _settings!.linkedIncome.toStringAsFixed(0);
          _limitController.text = _settings!.spendingLimit.toStringAsFixed(0);
        }
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BudgetConflictBottomSheet(exception: e),
        );
      }
    } catch (e) {
      if (mounted) {
        // Restore fields to last-saved values on failure
        if (_settings != null) {
          _incomeController.text = _settings!.linkedIncome.toStringAsFixed(0);
          _limitController.text = _settings!.spendingLimit.toStringAsFixed(0);
        }
        AppErrorHandler.show(context, e, fallback: 'Failed to save settings. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _onResetBudget() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text("Reset budget?",
          style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
        ),
        content: Text(
          "This will delete your current active budget from the backend and reset your app state. This action cannot be undone.",
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', color: const Color(0xFF0F172A).withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(fontFamily: 'DMSans', color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Reset", style: TextStyle(fontFamily: 'DMSans', color: const Color(0xFFDC2626), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      if (mounted) {
        ref.read(budgetStateProvider).resetBudget();
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.show(context, e, fallback: 'Failed to reset budget. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(16),
                vertical: getProportionateScreenHeight(16),
              ),
              child: Row(
                children: [
                  ZeyroIconButton(eventName: 'budget_settings_screen_back_tapped', 
                    icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () {Navigator.of(context).pop(); },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(24)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Budget settings",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(32),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(24)),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error ?? "Could not load settings", style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', color: const Color(0xFF9CA3AF))),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _fetchSettings,
                                child: Text("Retry", style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // === Editable Settings Card ===
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildEditableTile(
                                      icon: Icons.account_balance_wallet_outlined,
                                      title: "Income",
                                      subtitle: "",
                                      controller: _incomeController,
                                    ),
                                    Divider(height: 1, color: const Color(0xFF0F172A).withOpacity(0.05)),
                                    _buildEditableTile(
                                      icon: Icons.savings_outlined,
                                      title: "Total budget",
                                      subtitle: "",
                                      controller: _limitController,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: getProportionateScreenHeight(16)),

                              // === Read-only info card ===
                              if (_settings != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0F172A).withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Budget breakdown",
                                        style: TextStyle(fontFamily: 'DMSans', 
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _buildInfoRow("bills total", _settings!.billsTotal),
                                      const SizedBox(height: 10),
                                      _buildInfoRow("essential categories", _settings!.essentialCategoriesTotal),
                                      if (_settings!.lastReset != null) ...[
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Last reset",
                                              style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                                                fontSize: 13,
                                                color: const Color(0xFF0F172A).withOpacity(0.7),
                                              ),
                                            ),
                                            Text(
                                              DateFormat('MMM d, yyyy').format(_settings!.lastReset!),
                                              style: TextStyle(fontFamily: 'DMSans', 
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(height: getProportionateScreenHeight(20)),
                              ],

                              // === Save Button ===

                              SizedBox(
                                width: double.infinity,
                                child: ZeyroButton(eventName: 'budget_settings_screen_save_tapped', 
                                  onPressed: (_isSaving || !_hasChanges) ? null : _saveSettings,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    disabledBackgroundColor: const Color(0xFF0F172A).withOpacity(0.3),
                                    foregroundColor: const Color(0xFFFFFFFF),
                                    disabledForegroundColor: const Color(0xFFFFFFFF).withOpacity(0.7),
                                    minimumSize: const Size(double.infinity, 54),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    elevation: 0,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(color: const Color(0xFFFFFFFF), strokeWidth: 2),
                                        )
                                      : Text("Save settings",
                                          style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 15),
                                        ),
                                ),
                              ),

                              SizedBox(height: getProportionateScreenHeight(24)),

                              // === Danger Zone ===
                              ZeyroTapDetector(eventName: 'budget_settings_screen_reset_tapped', 
                                onTap: _onResetBudget,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: getProportionateScreenWidth(16),
                                    vertical: getProportionateScreenHeight(8),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626).withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.delete_outline_rounded, size: 14, color: const Color(0xFFDC2626)),
                                      const SizedBox(width: 6),
                                      Text("Reset & clear budget",
                                        style: TextStyle(fontFamily: 'DMSans', 
                                          fontSize: getProportionateScreenWidth(12),
                                          color: const Color(0xFFDC2626),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: getProportionateScreenHeight(40)),
                            ],
                          ),
                        ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildEditableTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(20),
        vertical: getProportionateScreenHeight(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF0F172A)),
          SizedBox(width: getProportionateScreenWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(15),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: getProportionateScreenHeight(2)),
                  Text(
                    subtitle,
                    style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                      fontSize: getProportionateScreenWidth(12),
                      color: const Color(0xFF0F172A).withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(12)),
          SizedBox(
            width: 110,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                LengthLimitingTextInputFormatter(8),
              ],
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                prefixText: '₹',
                prefixStyle: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(14),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: const Color(0xFF0F172A).withOpacity(0.15)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: const Color(0xFF0F172A).withOpacity(0.15)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', fontSize: 13, color: const Color(0xFF0F172A).withOpacity(0.7)),
        ),
        Text(
          _nf.format(amount),
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}


