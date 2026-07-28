import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_connection_provider.dart';

class BanksSelectionScreen extends ConsumerStatefulWidget {
  const BanksSelectionScreen({super.key});

  @override
  ConsumerState<BanksSelectionScreen> createState() => _BanksSelectionScreenState();
}

class _BanksSelectionScreenState extends ConsumerState<BanksSelectionScreen> {
  List<String> _selectedBanks = [];
  final List<String> _popularBanks = [
    'State Bank of India',
    'HDFC Bank',
    'Axis Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Union Bank of India',
    'Bank of India',
    'Indian Bank',
    'Central Bank of India',
    'Indian Overseas Bank',
    'UCO Bank',
    'Bank of Maharashtra',
    'Punjab & Sind Bank',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(assetConnectionProvider);
      final foundBanks = state.bankAccounts.map((b) => b.bankName).toSet();
      setState(() {
        _selectedBanks = foundBanks.toList();
      });
    });
  }

  void _onContinue() {
    final state = ref.read(assetConnectionProvider);
    final notifier = ref.read(assetConnectionProvider.notifier);
    
    final previouslyFound = state.bankAccounts.map((b) => b.bankName).toSet();
    final newlySelected = _selectedBanks.where((b) => !previouslyFound.contains(b)).toList();
    final deselectedFound = previouslyFound.where((b) => !_selectedBanks.contains(b)).toList();

    // Remove any deselected auto-found banks
    for (final bankName in deselectedFound) {
      notifier.removeBankByName(bankName);
    }

    if (newlySelected.isNotEmpty) {
      for (final bankName in newlySelected) {
        notifier.searchAndAddBank(bankName);
      }
      context.push('/banks-searching');
    } else {
      context.push('/banks-linking');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        const Text(
                          'Select Your Banks',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: Color(0xFF0F172A),
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.0,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'We found some banks linked to your phone number.',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _popularBanks.length,
                          itemBuilder: (context, index) {
                            final bankName = _popularBanks[index];
                            final isSelected = _selectedBanks.contains(bankName);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedBanks.remove(bankName);
                                  } else {
                                    _selectedBanks.add(bankName);
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  borderRadius: BorderRadius.zero,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    bankName.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: isSelected
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF475569),
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF0F172A)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFFCBD5E1),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
