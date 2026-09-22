import 'package:flutter/material.dart';
import 'package:astra_frontend/features/recurring/data/recurring_models.dart';

/// Client-side lookup of a display icon/logo for a payee name. No logo/icon
/// data comes from the backend, so this mirrors the same name-based
/// heuristic already used by [AddRecurringScreen]'s "Popular" row.
class _BrandVisual {
  const _BrandVisual({
    this.logoAsset,
    this.icon,
    required this.isDark,
    required this.backgroundColor,
    required this.dotColor,
  });

  final String? logoAsset;
  final IconData? icon;
  final bool isDark;
  final Color backgroundColor;
  final Color dotColor;
}

const _defaultVisual = _BrandVisual(
  icon: Icons.subscriptions_rounded,
  isDark: true,
  backgroundColor: Colors.black87,
  dotColor: Color(0xFFD6FF3F),
);

final Map<String, _BrandVisual> _brandVisuals = {
  'netflix': const _BrandVisual(
    logoAsset: 'lib/core/images/Netflix_icon.svg',
    isDark: true,
    backgroundColor: Colors.black,
    dotColor: Color(0xFFE5803E),
  ),
  'spotify': const _BrandVisual(
    logoAsset: 'lib/core/images/spotify-icon.svg',
    isDark: true,
    backgroundColor: Color(0xFF1DB954),
    dotColor: Color(0xFFC0D72F),
  ),
  'disney': const _BrandVisual(
    logoAsset: 'lib/core/images/Disney.svg',
    isDark: true,
    backgroundColor: Color(0xFF001524),
    dotColor: Color(0xFF030B17),
  ),
  'youtube': const _BrandVisual(
    logoAsset: 'lib/core/images/youtube-icon.svg',
    isDark: false,
    backgroundColor: Colors.white,
    dotColor: Color(0xFFFF0000),
  ),
  'notion': const _BrandVisual(
    logoAsset: 'lib/core/images/Notion-logo.svg',
    isDark: false,
    backgroundColor: Colors.white,
    dotColor: Color(0xFFE5803E),
  ),
  'perplexity': const _BrandVisual(
    logoAsset: 'lib/core/images/Perplexity_Black_0.svg',
    isDark: true,
    backgroundColor: Colors.black87,
    dotColor: Color(0xFFC0D72F),
  ),
  'claude': const _BrandVisual(
    logoAsset: 'lib/core/images/Claude_AI_symbol.svg',
    isDark: true,
    backgroundColor: Color(0xFFD97757),
    dotColor: Color(0xFFD97757),
  ),
  'canva': const _BrandVisual(
    logoAsset: 'lib/core/images/canva.svg',
    isDark: false,
    backgroundColor: Color(0xFF00C4CC),
    dotColor: Color(0xFF00C4CC),
  ),
  'prime': const _BrandVisual(
    icon: Icons.movie_creation_outlined,
    isDark: true,
    backgroundColor: Color(0xFF00A8E1),
    dotColor: Color(0xFF00A8E1),
  ),
  'amazon': const _BrandVisual(
    icon: Icons.shopping_bag_outlined,
    isDark: true,
    backgroundColor: Color(0xFF232F3E),
    dotColor: Color(0xFFFF9900),
  ),
  'apple': const _BrandVisual(
    icon: Icons.apple,
    isDark: true,
    backgroundColor: Colors.black,
    dotColor: Colors.white,
  ),
  'google': const _BrandVisual(
    icon: Icons.cloud_outlined,
    isDark: false,
    backgroundColor: Colors.white,
    dotColor: Color(0xFF4285F4),
  ),
  'airtel': const _BrandVisual(
    icon: Icons.wifi,
    isDark: true,
    backgroundColor: Color(0xFFE40000),
    dotColor: Color(0xFFE40000),
  ),
  'cult': const _BrandVisual(
    icon: Icons.fitness_center_rounded,
    isDark: true,
    backgroundColor: Colors.black87,
    dotColor: Color(0xFFFF3278),
  ),
};

_BrandVisual _visualForName(String name) {
  final lower = name.toLowerCase();
  for (final entry in _brandVisuals.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return _defaultVisual;
}

String _uiType(String frequency) {
  switch (frequency.toUpperCase()) {
    case 'YEARLY':
      return 'Yearly';
    case 'QUARTERLY':
      return 'Quarterly';
    case 'MONTHLY':
    default:
      return 'Monthly';
  }
}

String _uiStatus(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
      return 'active';
    case 'PAUSED':
      return 'paused';
    default:
      // REVOKED, EXPIRED, PENDING → treated as inactive/cancelled in the UI.
      return 'cancelled';
  }
}

/// Converts a [RecurringMandate] into the `Map<String, dynamic>` shape the
/// existing (visually-untouched) recurring widgets expect: id, day, month,
/// name, type, amount, logoAsset, icon, isDark, backgroundColor, dotColor,
/// status, bank.
Map<String, dynamic> paymentMapFromMandate(RecurringMandate mandate) {
  final visual = _visualForName(mandate.payeeName);
  final nextDebit = mandate.nextDebitDateTime ?? DateTime.now();
  final type = _uiType(mandate.frequency);

  return <String, dynamic>{
    'id': mandate.mandateId,
    'mandateId': mandate.mandateId,
    'day': nextDebit.day,
    if (type == 'Yearly') 'month': nextDebit.month,
    'name': mandate.payeeName,
    'type': type,
    'isYearly': type == 'Yearly',
    'amount': mandate.maxAmount,
    'logoAsset': visual.logoAsset,
    'icon': visual.logoAsset == null ? visual.icon : null,
    'isDark': visual.isDark,
    'backgroundColor': visual.backgroundColor,
    'dotColor': visual.dotColor,
    'status': _uiStatus(mandate.status),
    'bank': mandate.bankName ?? '',
    'category': mandate.category,
    'nextDebitDate': mandate.nextDebitDate, // epoch seconds
  };
}
