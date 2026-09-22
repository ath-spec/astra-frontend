// ============================================================
// FILE: lib/core/widgets/merchant_logo_avatar.dart
// Displays a merchant/brand logo if an asset exists in lib/core/images,
// otherwise falls back to a clean category icon with soft tint.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MerchantLogoAvatar extends StatelessWidget {
  final String merchantName;
  /// Optional raw merchant string from the API (e.g. "zomato"). When set,
  /// logo lookup tries this first, then falls back to [merchantName].
  final String? logoKey;
  final String category;
  final double size;
  final double borderRadius;
  final bool isDebit;

  const MerchantLogoAvatar({
    super.key,
    required this.merchantName,
    this.logoKey,
    required this.category,
    this.size = 38,
    this.borderRadius = 10,
    this.isDebit = true,
  });

  static String? getLogoAsset(String name) {
    final lower = name.toLowerCase().trim();
    if (lower.contains('zomato')) return 'lib/core/images/zomato.svg';
    if (lower.contains('netflix')) return 'lib/core/images/Netflix_icon.svg';
    if (lower.contains('spotify')) return 'lib/core/images/spotify-icon.svg';
    if (lower.contains('youtube')) return 'lib/core/images/youtube-icon.svg';
    if (lower.contains('disney')) return 'lib/core/images/Disney.svg';
    if (lower.contains('notion')) return 'lib/core/images/Notion-logo.svg';
    if (lower.contains('perplexity')) return 'lib/core/images/Perplexity_Black_0.svg';
    if (lower.contains('claude')) return 'lib/core/images/Claude_AI_symbol.svg';
    if (lower.contains('canva')) return 'lib/core/images/canva.svg';
    if (lower.contains('google')) return 'lib/core/images/google_logo.webp';
    if (lower.contains('hdfc')) return 'lib/core/images/hdfc_logo.webp';
    if (lower.contains('icici')) return 'lib/core/images/icici.webp';
    if (lower.contains('axis')) return 'lib/core/images/axis_logo.webp';
    if (lower.contains('sbi') || lower.contains('state bank')) return 'lib/core/images/sbi_logo.webp';
    if (lower.contains('kotak')) return 'lib/core/images/kotak.webp';
    if (lower.contains('bank of baroda') || lower.contains('bob')) return 'lib/core/images/bankofbaroda_logo.webp';
    if (lower.contains('bank of india') || lower.contains('boi')) return 'lib/core/images/bankofindia_logo.webp';
    if (lower.contains('canara')) return 'lib/core/images/canara_logo.webp';
    if (lower.contains('pnb') || lower.contains('punjab national')) return 'lib/core/images/pnb.webp';
    if (lower.contains('indusind')) return 'lib/core/images/indusind_logo.webp';
    if (lower.contains('yes bank') || lower.contains('yesbank')) return 'lib/core/images/yesbank_logo.webp';
    if (lower.contains('union bank')) return 'lib/core/images/uniobank_logo.webp';
    if (lower.contains('maharashtra')) return 'lib/core/images/bank_of_maharashtra_logo.webp';
    if (lower.contains('indian overseas')) return 'lib/core/images/indian_overseas_bank_logo.webp';
    if (lower.contains('indian bank')) return 'lib/core/images/indian_bank_logo.webp';
    if (lower.contains('uco')) return 'lib/core/images/uco_bank_logo.webp';
    if (lower.contains('punjab & sind') || lower.contains('punjab and sindh') || lower.contains('psb')) {
      return 'lib/core/images/punjab_sindh_bank_logo.webp';
    }
    if (lower.contains('mfcentral') || lower.contains('mf central')) {
      return 'lib/core/images/mfcentral_logo.webp';
    }
    return null;
  }

  Color _getCategoryColor(String cat, String merchant) {
    final c = cat.toLowerCase();
    final m = merchant.toLowerCase();
    if (c.contains('food') || c.contains('dining') || m.contains('zomato') || m.contains('swiggy')) {
      return const Color(0xFFF97316);
    } else if (c.contains('shopping') || m.contains('amazon') || m.contains('flipkart')) {
      return const Color(0xFF2563EB);
    } else if (c.contains('transport') || m.contains('uber') || m.contains('ola')) {
      return const Color(0xFF059669);
    } else if (c.contains('entertainment') || m.contains('netflix') || m.contains('spotify')) {
      return const Color(0xFF7C3AED);
    } else if (c.contains('bill') || c.contains('utilities')) {
      return const Color(0xFFF43F5E);
    } else if (!isDebit || c.contains('income') || m.contains('salary')) {
      return const Color(0xFF16A34A);
    }
    return const Color(0xFF64748B);
  }

  IconData _getCategoryIcon(String cat, String merchant) {
    final c = cat.toLowerCase();
    final m = merchant.toLowerCase();
    if (c.contains('food') || c.contains('dining') || m.contains('zomato') || m.contains('swiggy')) {
      return Icons.restaurant_rounded;
    } else if (c.contains('shopping') || m.contains('amazon') || m.contains('flipkart')) {
      return Icons.shopping_bag_rounded;
    } else if (c.contains('transport') || m.contains('uber') || m.contains('ola')) {
      return Icons.directions_car_rounded;
    } else if (c.contains('entertainment') || m.contains('netflix') || m.contains('spotify')) {
      return Icons.movie_rounded;
    } else if (c.contains('bill') || c.contains('utilities')) {
      return Icons.receipt_long_rounded;
    } else if (!isDebit || c.contains('income') || m.contains('salary')) {
      return Icons.arrow_downward_rounded;
    }
    return Icons.credit_card_rounded;
  }

  @override
  Widget build(BuildContext context) {
    // Try the raw API merchant key first (more reliable), then the display name.
    final logoAsset = (logoKey != null ? getLogoAsset(logoKey!) : null) ?? getLogoAsset(merchantName);

    if (logoAsset != null) {
      final isSvg = logoAsset.endsWith('.svg');
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: isSvg
                ? SvgPicture.asset(
                    logoAsset,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    logoAsset,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      );
    }

    final color = _getCategoryColor(category, merchantName);
    final icon = _getCategoryIcon(category, merchantName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        size: size * 0.46,
        color: color,
      ),
    );
  }
}
