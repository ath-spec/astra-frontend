import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profiling_provider.dart';

class ProfilingStatusScreen extends ConsumerStatefulWidget {
  const ProfilingStatusScreen({super.key});

  @override
  ConsumerState<ProfilingStatusScreen> createState() => _ProfilingStatusScreenState();
}

class _ProfilingStatusScreenState extends ConsumerState<ProfilingStatusScreen> {
  Timer? _navigationTimer;

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _scheduleNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profilingProvider);

    ref.listen<ProfilingState>(profilingProvider, (previous, next) {
      if (next.isSubmitted && (previous == null || !previous.isSubmitted)) {
        _scheduleNavigation();
      }
    });

    // In case we land here and it's already submitted
    if (state.isSubmitted && _navigationTimer == null) {
      _scheduleNavigation();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isSubmitted
                ? Column(
                    key: const ValueKey('submitted'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0D9488),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            size: 48,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Details submitted',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Column(
                    key: const ValueKey('submitting'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                          strokeWidth: 4,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Submitting your details...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
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
