import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/privacy_provider.dart';
import '../../../core/utils/privacy_formatter.dart';
import '../data/fd_providers.dart';
import '../widgets/fds_header.dart';
import '../widgets/fd_card.dart';
import 'package:intl/intl.dart' as intl;

class FDsScreen extends ConsumerStatefulWidget {
  const FDsScreen({super.key});

  @override
  ConsumerState<FDsScreen> createState() => _FDsScreenState();
}

enum FDViewMode { summary, expanded, table }

class _FDsScreenState extends ConsumerState<FDsScreen> {
  FDViewMode _viewMode = FDViewMode.summary;

  final Set<String> _activeFilters = {};
  String _activeSort = 'Maturity Value';

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(privacyProvider);
    final fdsAsync = ref.watch(activeFdsProvider);

    List<FDData> fdList = [];
    double totalPrincipal = 0.0;
    double totalAccrued = 0.0;

    if (fdsAsync.hasValue && fdsAsync.value!.isNotEmpty) {
      final accounts = fdsAsync.value!;
      totalPrincipal = accounts.fold<double>(0.0, (acc, a) => acc + a.principalAmount);
      fdList = accounts.map((a) {
        final alloc = totalPrincipal > 0 ? (a.principalAmount / totalPrincipal * 100) : 0.0;
        return FDData(
          accountNumber: a.fdAccountNumber,
          principalAmount: a.principalAmount,
          interestRate: a.interestRate,
          tenureMonths: a.tenureMonths,
          maturityAmount: a.maturityAmount,
          maturityDate: a.maturityDateTime,
          status: a.status,
          allocation: double.parse(alloc.toStringAsFixed(1)),
        );
      }).toList();
      totalAccrued = fdList.fold<double>(0.0, (acc, f) => acc + f.accruedInterest);
    }

    final String liveTotalStr = '₹${intl.NumberFormat('#,##,###').format(totalPrincipal.round())}';
    final String accruedStr = totalAccrued > 0
        ? '↑ ₹${intl.NumberFormat('#,##,###').format(totalAccrued.round())} interest accrued'
        : '';

    final filteredFds = fdList.where((f) {
      final hasActive = _activeFilters.contains('Active');
      final hasMatured = _activeFilters.contains('Matured');
      if (!hasActive && !hasMatured) return true;
      if (hasActive && hasMatured) return true;
      if (hasActive) return f.status.toUpperCase() == 'ACTIVE';
      return f.status.toUpperCase() != 'ACTIVE';
    }).toList();

    filteredFds.sort((a, b) {
      if (_activeSort == 'Maturity Value') {
        return b.maturityAmount.compareTo(a.maturityAmount);
      } else if (_activeSort == 'Interest Rate') {
        return b.interestRate.compareTo(a.interestRate);
      } else if (_activeSort == 'Tenure') {
        return b.tenureMonths.compareTo(a.tenureMonths);
      } else if (_activeSort == 'Alphabetically') {
        return a.accountNumber.compareTo(b.accountNumber);
      }
      return 0;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: FDsHeaderDelegate(
              safeAreaTop: MediaQuery.paddingOf(context).top,
              totalAmount: PrivacyFormatter.obscure(liveTotalStr, isLocked),
              accruedLine: PrivacyFormatter.obscure(accruedStr, isLocked),
              onBackTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              onAddAccountsTap: () {
                context.push('/mf-fd');
              },
              isLocked: isLocked,
              onLockTap: () {
                ref.read(privacyProvider.notifier).state = !isLocked;
              },
            ),
          ),

          if (fdsAsync.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Couldn't load your fixed deposits.",
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref.invalidate(activeFdsProvider),
                        child: const Text(
                          'RETRY',
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Holdings',
                    style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                    padding: EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildViewToggleIcon(Icons.view_agenda_rounded, FDViewMode.summary),
                        SizedBox(width: 4),
                        _buildViewToggleIcon(Icons.view_stream_rounded, FDViewMode.expanded),
                        SizedBox(width: 4),
                        _buildViewToggleIcon(Icons.grid_view_rounded, FDViewMode.table),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildChip('Sort by', icon: Icons.sort_rounded, isOutline: true),
                  SizedBox(width: 8),
                  _buildChip('Active'),
                  SizedBox(width: 8),
                  _buildChip('Matured'),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
                switchOutCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
                child: _viewMode == FDViewMode.table ? SizedBox.shrink() : _buildListHeader(),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 40 + MediaQuery.paddingOf(context).bottom),
            sliver: _viewMode == FDViewMode.table
                ? SliverToBoxAdapter(child: _buildUnifiedTable(filteredFds, isLocked))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FDCard(
                          fd: filteredFds[index],
                          forceExpanded: _viewMode == FDViewMode.expanded,
                          isLocked: isLocked,
                        );
                      },
                      childCount: filteredFds.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      key: const ValueKey('listHeader'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _activeFilters.isEmpty ? 'ALL FIXED DEPOSITS' : _activeFilters.join(', ').toUpperCase(),
          style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildUnifiedTable(List<FDData> filteredFds, bool isLocked) {
    const double rowHeight = 72.0;
    const double headerHeight = 40.0;

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            decoration: BoxDecoration(border: Border(right: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
            child: Column(
              children: [
                Container(
                  height: headerHeight,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text('FDs', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF0F172A))),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
                ...filteredFds.map((fd) {
                  final last4 = fd.accountNumber.length >= 4 ? fd.accountNumber.substring(fd.accountNumber.length - 4) : fd.accountNumber;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _viewMode = FDViewMode.expanded),
                    child: Container(
                      height: rowHeight,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: const Color(0xFFF1F5F9), width: 1))),
                      child: Text(
                        'FD •••$last4',
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: Row(
                      children: [
                        _buildTableHeaderCell('AMOUNT', 100),
                        _buildTableHeaderCell('RATE', 80, isCenter: true),
                        _buildTableHeaderCell('MATURITY', 110, isCenter: true),
                        _buildTableHeaderCell('TENURE', 80, isRight: true),
                      ],
                    ),
                  ),
                  ...filteredFds.map((fd) {
                    final dateFmt = intl.DateFormat('d MMM yy');
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _viewMode = FDViewMode.expanded),
                      child: Container(
                        height: rowHeight,
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: const Color(0xFFF1F5F9), width: 1))),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                PrivacyFormatter.obscure(intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(fd.principalAmount), isLocked),
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ),
                            Container(
                              width: 80,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              child: Text(
                                isLocked ? PrivacyFormatter.cypher : '${fd.interestRate.toStringAsFixed(2)}%',
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ),
                            Container(
                              width: 110,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              child: Text(
                                dateFmt.format(fd.maturityDate),
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ),
                            Container(
                              width: 80,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.centerRight,
                              child: Text(
                                isLocked ? PrivacyFormatter.cypher : '${fd.tenureMonths}mo',
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String title, double width, {bool isRight = false, bool isCenter = false}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: isRight ? Alignment.centerRight : (isCenter ? Alignment.center : Alignment.centerLeft),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF0F172A))),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildViewToggleIcon(IconData icon, FDViewMode mode) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: const Cubic(0.23, 1.0, 0.32, 1.0),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: Offset(0, 2))] : null,
        ),
        child: Icon(icon, size: 16, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildChip(String label, {IconData? icon, bool isOutline = false}) {
    final isSelected = isOutline ? false : _activeFilters.contains(label);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (label == 'Sort by') {
          _showSortByBottomSheet(context);
          return;
        }
        if (!isOutline) {
          setState(() {
            if (_activeFilters.contains(label)) {
              _activeFilters.remove(label);
            } else {
              _activeFilters.add(label);
            }
          });
        }
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isOutline ? 1.0 : (isSelected ? 1.0 : 0.6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: const Cubic(0.23, 1.0, 0.32, 1.0),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : (isSelected ? Colors.white : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isOutline ? const Color(0xFFE2E8F0) : (isSelected ? const Color(0xFFE2E8F0) : Colors.transparent)),
            boxShadow: isSelected && !isOutline ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Color(0xFF0F172A)),
                SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isOutline ? const Color(0xFF0F172A) : (isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortByBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sort by', style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                        GestureDetector(
                          onTap: () => setModalState(() => _activeSort = 'Maturity Value'),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text('Reset', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildSortOption('Maturity Value', setModalState),
                    _buildSortOption('Interest Rate', setModalState),
                    _buildSortOption('Tenure', setModalState),
                    _buildSortOption('Alphabetically', setModalState),
                    SizedBox(height: 32),
                    GestureDetector(
                      onTap: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: Center(
                          child: Text('Apply', style: TextStyle(fontFamily: 'DMSans', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(String label, StateSetter setModalState) {
    final isSelected = _activeSort == label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setModalState(() => _activeSort = label),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1), width: 1.5),
              ),
            ),
            SizedBox(width: 12),
            Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, color: const Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }
}
