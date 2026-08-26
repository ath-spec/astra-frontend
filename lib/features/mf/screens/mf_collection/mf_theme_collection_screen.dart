import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../data/catalog_providers.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

class MfThemeCollectionScreen extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>>? funds;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;

  const MfThemeCollectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.funds,
    this.imagePath,
    this.icon,
    this.iconColor,
  });

  @override
  ConsumerState<MfThemeCollectionScreen> createState() => _MfThemeCollectionScreenState();
}

class _MfThemeCollectionScreenState extends ConsumerState<MfThemeCollectionScreen> {
  String _returnPeriod = '3Y'; // '1Y', '3Y', '5Y'

  void _cycleReturnPeriod() {
    setState(() {
      if (_returnPeriod == '1Y') {
        _returnPeriod = '3Y';
      } else if (_returnPeriod == '3Y') {
        _returnPeriod = '5Y';
      } else {
        _returnPeriod = '1Y';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(allCatalogFundsProvider);

    // When funds are passed in explicitly (e.g. a pre-filtered theme list),
    // that data is already resolved by the caller — render it as-is.
    final usingProvidedFunds = widget.funds != null;
    final displayFunds = widget.funds ??
        (catalogAsync.valueOrNull ?? const [])
            .map((f) => {
                  'scheme_code': f.schemeCode,
                  'name': f.schemeName,
                  'category': f.category,
                  'returns': {
                    '1Y': f.returns1y != null ? '${f.returns1y!.toStringAsFixed(1)}%' : '--',
                    '3Y': f.returns3y != null ? '${f.returns3y!.toStringAsFixed(1)}%' : '--',
                    '5Y': f.returns5y != null ? '${f.returns5y!.toStringAsFixed(1)}%' : '--',
                  },
                })
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(4),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
            return Center(
              child: SizedBox(
                width: maxWidth,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Header Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.subtitle,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 10,
                                  color: Color(0xFF64748B), // Slate 500
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Graphic
                        if (widget.imagePath != null)
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Image.asset(
                              widget.imagePath!,
                              fit: BoxFit.contain,
                            ),
                          )
                        else
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Icon(
                              widget.icon ?? Icons.pie_chart,
                              color: widget.iconColor ?? const Color(0xFF00C75A),
                              size: 60,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Period Selector
                    Row(
                      children: ['1Y', '3Y', '5Y'].map((p) {
                        final isSelected = _returnPeriod == p;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text('$p Returns'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _returnPeriod = p);
                            },
                            selectedColor: const Color(0xFF0F172A),
                            labelStyle: TextStyle(
                              fontFamily: 'DMSans',
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Fund List
                    if (!usingProvidedFunds && catalogAsync.isLoading)
                      ..._buildLoadingRows()
                    else if (!usingProvidedFunds && catalogAsync.hasError)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            "Couldn't load funds.",
                            style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B)),
                          ),
                        ),
                      )
                    else if (displayFunds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            'No funds available in this collection yet.',
                            style: TextStyle(fontFamily: 'DMSans', color: Color(0xFF64748B)),
                          ),
                        ),
                      )
                    else
                      ...displayFunds.map((fund) => _buildFundRow(fund)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildLoadingRows() {
    return List.generate(
      5,
      (index) => const Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: AppThemeShimmerCard(
          height: 72,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          barWidths: [140, 100, 60, 60],
        ),
      ),
    );
  }

  Widget _buildFundRow(Map<String, dynamic> fund) {
    final schemeCode = fund['scheme_code']?.toString() ?? '';
    final name = fund['name']?.toString() ?? 'Fund';
    return Column(
      children: [
        InkWell(
          onTap: () => MfFundProfileScreen.showModal(
              context, schemeCode.isNotEmpty ? schemeCode : name),
          onLongPress: _cycleReturnPeriod,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                // Logo
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1) : '?',
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars, color: Colors.deepOrange, size: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fund['category']?.toString() ?? '',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Returns
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    (fund['returns'] as Map?)?[_returnPeriod]?.toString() ?? '--',
                    key: ValueKey<String>('${name}_$_returnPeriod'),
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C75A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Dashed border (simulated with a standard very light border for now)
        Container(
          height: 1,
          color: const Color(0xFFF8F9FA),
        ),
      ],
    );
  }
}
