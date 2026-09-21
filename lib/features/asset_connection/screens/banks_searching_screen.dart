import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_connection_provider.dart';
import '../../chat/widgets/thinking_orbs/thinking_orb.dart';

/// Screen 2 of Banks Flow: Fetching Screen (Image 3) in clean light mode.
/// Displays pulsing dots, skeleton account cards, and auto-navigates to HomeScreen.
class BanksSearchingScreen extends ConsumerStatefulWidget {
  const BanksSearchingScreen({super.key});

  @override
  ConsumerState<BanksSearchingScreen> createState() => _BanksSearchingScreenState();
}

class _BanksSearchingScreenState extends ConsumerState<BanksSearchingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_navigated) return;
    _navigated = true;
    // extra carries the real Future for whatever network work this screen
    // is covering (e.g. banks_linking_screen's searchAndAddBank calls) when
    // the caller provided one. Previously this screen navigated back on a
    // flat 2600ms timer no matter what — if the actual add/search took
    // longer than that (any real network latency), the user landed back on
    // the previous screen before their new bank had actually appeared. Now
    // it waits for genuine completion (still floored at 2600ms so the
    // animation never feels like a flash for fast responses).
    final extra = GoRouterState.of(context).extra;
    final pending = extra is Future ? extra : null;
    _waitAndNavigate(pending);
  }

  Future<void> _waitAndNavigate(Future<void>? pending) async {
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 2600));
    if (pending != null) {
      // Swallow errors from the pending work itself here — searchAndAddBank
      // already handles its own failures internally (offline fallback);
      // this wait only needs to know when it's done, not whether it threw.
      await Future.wait([minDelay, pending.catchError((_) {})]);
    } else {
      await minDelay;
    }
    if (!mounted) return;
    final state = ref.read(assetConnectionProvider);
    if (state.step == AssetConnectionStep.banksLinkingProgress) {
      await ref.read(assetConnectionProvider.notifier).completeBankLinking();
    }
    if (!mounted) return;
    context.pushReplacement('/banks-linking');
  }

  @override
  void dispose() {
    _pulseController.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetConnectionProvider);
    final isLinking = state.step == AssetConnectionStep.banksLinkingProgress;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Title
                    Text(
                      isLinking ? 'Securely linking your Banks' : 'Securely fetching your Banks',
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        color: Color(0xFF0F172A),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 11),

                    // Subtitle
                    Text(
                      isLinking
                          ? "HANG TIGHT. WE'RE SECURELY LINKING YOUR ACCOUNTS,\nTHIS WILL ONLY TAKE A MOMENT."
                          : "HANG TIGHT. WE'RE SECURELY PULLING YOUR ACCOUNTS,\nTHIS WILL ONLY TAKE A MOMENT.",
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        color: Color(0xFF9CA3AF),
                        fontSize: 10,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Center(
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF5BA1F7),
                            Color(0xFF4F46E5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const ThinkingOrb(
                          mode: 'globe',
                          size: 140,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'POWERED BY RBI-REGULATED ACCOUNT AGGREGATOR ',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 9,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              Icons.change_history_rounded,
              color: Color(0xFF1E3A8A),
              size: 11,
            ),
            const SizedBox(width: 2),
            const Text(
              'FINARKEIN',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E3A8A),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
