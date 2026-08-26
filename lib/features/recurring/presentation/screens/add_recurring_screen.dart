
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/extensions/string_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:astra_frontend/core/network/api_exception.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/data/recurring_providers.dart';

class AddRecurringScreen extends ConsumerStatefulWidget {
  const AddRecurringScreen({super.key});

  @override
  ConsumerState<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends ConsumerState<AddRecurringScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty) {
      setState(() => _error = 'Enter a subscription name');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDateEpochSeconds = today.millisecondsSinceEpoch ~/ 1000;

      await ref.read(recurringRepositoryProvider).createMandate(
            payeeName: name,
            mandateAmount: amount,
            mandateFrequency: 'MONTHLY',
            mandateStartDate: startDateEpochSeconds,
            category: 'SUBSCRIPTION',
          );

      invalidateRecurringProviders(ref);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      final message = e is ApiException ? e.message : 'Could not add subscription. Please try again.';
      if (!mounted) return;
      setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Material(
        color: const Color(0xFFFBF8E7),
        child: Column(
          children: [
            // Header
            _buildHeader(context, topPadding),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: getProportionateScreenHeight(16)),
                        _buildBankHeroCard(),
                        SizedBox(height: getProportionateScreenHeight(28)),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: getProportionateScreenWidth(16),
                              ),
                              child: Text(
                                "Or add manually",
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: getProportionateScreenWidth(9),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: getProportionateScreenHeight(24)),
                        Text(
                          "Popular",
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: getProportionateScreenWidth(13),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(14)),
                        _buildPopularIcons(),
                        SizedBox(height: getProportionateScreenHeight(32)),
                        _buildManualInput(
                          "Subscription name",
                          controller: _nameController,
                        ),
                        SizedBox(height: getProportionateScreenHeight(12)),
                        _buildManualInput(
                          "Amount (₹ per month)",
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                        ),
                        if (_error != null) ...[
                          SizedBox(height: getProportionateScreenHeight(12)),
                          Container(
                            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: getProportionateScreenWidth(12),
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: getProportionateScreenHeight(24),
                            ), // Minimum gap
                            GestureDetector(
                              onTap: _isSubmitting ? null : _submit,
                              child: Container(
                                height: getProportionateScreenHeight(48),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                    getProportionateScreenWidth(4),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Continue",
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: getProportionateScreenWidth(15),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: getProportionateScreenHeight(20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(16),
        topPadding + getProportionateScreenHeight(10),
        getProportionateScreenWidth(16),
        getProportionateScreenHeight(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: getProportionateScreenWidth(38),
              height: getProportionateScreenWidth(38),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFECEBDB)),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            "Add subscription",
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: getProportionateScreenWidth(14),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(38)),
        ],
      ),
    );
  }

  Widget _buildBankHeroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EBD1), // Light sage green
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
      ),
      child: Column(
        children: [
          // Bank Icon Container
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: getProportionateScreenWidth(60),
                height: getProportionateScreenWidth(60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    getProportionateScreenWidth(4),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              Container(
                width: getProportionateScreenWidth(22),
                height: getProportionateScreenWidth(22),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          Text(
            "Connect your bank",
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: getProportionateScreenWidth(18),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(6)),
          Text(
            "Find your subscriptions automatically with bank-level security.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: getProportionateScreenWidth(11),
              color: Colors.black.withValues(alpha: 0.5),
              height: 1.3,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(24)),
          Container(
            width: double.infinity,
            height: getProportionateScreenHeight(44),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(
                getProportionateScreenWidth(4),
              ),
            ),
            child: Text(
              "Link account",
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: getProportionateScreenWidth(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 10,
                color: Colors.black.withValues(alpha: 0.3),
              ),
              SizedBox(width: getProportionateScreenWidth(4)),
              Text(
                "Secure 256-bit encryption. read-only access.",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: getProportionateScreenWidth(8),
                  color: Colors.black.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularIcons() {
    final List<Map<String, dynamic>> popular = [
      {'name': 'Netflix', 'logo': 'lib/core/images/Netflix_icon.svg'},
      {'name': 'Spotify', 'logo': 'lib/core/images/spotify-icon.svg'},
      {'name': 'Disney+', 'logo': 'lib/core/images/Disney.svg'},
      {'name': 'Youtube', 'logo': 'lib/core/images/youtube-icon.svg'},
      {'name': 'Notion', 'logo': 'lib/core/images/Notion-logo.svg'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: popular.map((item) {
          return Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(18)),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _nameController.text = item['name'].toString();
                  _error = null;
                });
              },
              child: Column(
                children: [
                  SvgPicture.asset(
                    item['logo'].toString(),
                    fit: BoxFit.contain,
                    width: getProportionateScreenWidth(48),
                    height: getProportionateScreenWidth(48),
                  ),
                  SizedBox(height: getProportionateScreenHeight(8)),
                  Text(
                    item['name'].toString().toCapitalized(),
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: getProportionateScreenWidth(9),
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildManualInput(
    String hint, {
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: getProportionateScreenHeight(48),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
        border: Border.all(color: const Color(0xFFECEBDB)),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: getProportionateScreenWidth(12),
          color: Colors.black,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'DMSans',
            fontSize: getProportionateScreenWidth(12),
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
