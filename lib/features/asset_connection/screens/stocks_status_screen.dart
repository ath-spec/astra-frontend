import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/asset_connection_provider.dart';

/// Screen displaying Stocks search result (Image 3).
/// Supports both cases: "No stocks found" (default, Image 3) and "Stocks found" (via demo toggle).
class StocksStatusScreen extends ConsumerStatefulWidget {
  const StocksStatusScreen({super.key});

  @override
  ConsumerState<StocksStatusScreen> createState() => _StocksStatusScreenState();
}

class _StocksStatusScreenState extends ConsumerState<StocksStatusScreen> {
  bool _hasStocks = false; // Default to Image 3 (No stocks found)

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider.notifier).pendingPhone;
    final displayPhone = phone.isNotEmpty ? phone : '8826473535';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: TextButton.icon(
          onPressed: () => setState(() => _hasStocks = !_hasStocks),
          icon: Icon(
            _hasStocks ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
            color: const Color(0xFF0D9488),
            size: 24,
          ),
          label: Text(
            _hasStocks ? 'Demo: Stocks Found' : 'Demo: No Stocks Found',
            style: const TextStyle(color: Color(0xFF0D9488), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                // Icon Badge (Image 3)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _hasStocks ? const Color(0xFF065F46).withValues(alpha: 0.3) : const Color(0xFF161922),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _hasStocks ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFF20232C),
                          ),
                        ),
                        child: Icon(
                          _hasStocks ? Icons.show_chart_rounded : Icons.show_chart_rounded,
                          color: _hasStocks ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                          size: 32,
                        ),
                      ),
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _hasStocks ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _hasStocks ? Icons.check_rounded : Icons.info_outline_rounded,
                            color: const Color(0xFF0B0F19),
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  _hasStocks ? '2 Demat Accounts found for\nthis PAN and mobile' : 'No stocks found for this\nPAN and mobile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle (Image 3)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF), height: 1.4),
                    children: [
                      TextSpan(
                        text: _hasStocks
                            ? 'We found active stock holdings linked to mobile number '
                            : 'Please ensure that this PAN and mobile\nnumber ',
                      ),
                      TextSpan(
                        text: displayPhone,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: _hasStocks ? ' and PAN ENSPB2987N.' : ' are linked to your\ndemat account',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // PAN Card (Image 3)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161922),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF20232C)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your PAN Number',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'ENSPB2987N',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF292C37),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Primary CTA (Image 3: Re-generate OTP / Connect)
                ElevatedButton(
                  onPressed: () {
                    if (_hasStocks) {
                      ref.read(assetConnectionProvider.notifier).connectFoundStocks();
                      context.pop();
                    } else {
                      ref.read(assetConnectionProvider.notifier).retryStocksOtp();
                      context.pushReplacement('/stocks-otp');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasStocks ? const Color(0xFF0D9488) : const Color(0xFF20232C),
                    foregroundColor: _hasStocks ? Colors.white : const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _hasStocks ? 'CONNECT DEMAT ACCOUNTS' : 'Re-generate OTP to fetch stocks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _hasStocks ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Secondary CTA (Image 3: Continue without stocks)
                ElevatedButton(
                  onPressed: () {
                    ref.read(assetConnectionProvider.notifier).continueWithoutStocks();
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2028),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue without stocks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
