import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/dues_sheet/all_time_tab.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/dues_sheet/this_month_tab.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/dues_sheet/paused_tab.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/dues_sheet/trials_tab.dart';
class RecurringDuesSheet extends StatefulWidget {
  final TabController tabController;
  final FocusNode searchFocusNode;
  final TextEditingController searchController;
  final ValueNotifier<String> searchQuery;
  final DateTime currentMonth;
  final DraggableScrollableController controller;
  final List<Map<String, dynamic>> payments;
  final Function(String, String, {DateTime? pauseUntil}) onStatusChanged;

  const RecurringDuesSheet({
    super.key,
    required this.tabController,
    required this.searchFocusNode,
    required this.searchController,
    required this.searchQuery,
    required this.currentMonth,
    required this.controller,
    required this.payments,
    required this.onStatusChanged,
  });

  @override
  State<RecurringDuesSheet> createState() => _RecurringDuesSheetState();
}

class _RecurringDuesSheetState extends State<RecurringDuesSheet> {
  final List<String> _tabs = ['this month', 'paused', 'trials', 'all time'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredPayments(String query) {
    if (query.isEmpty) return widget.payments;
    return widget.payments.where((p) {
      final name = p['name']?.toString().toLowerCase() ?? "";
      return name.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        controller: widget.controller,
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return ZeyroTapDetector(eventName: 'recurring_dues_sheet_unfocus_tapped', 
            onTap: () {
              if (widget.searchFocusNode.hasFocus) {
                widget.searchFocusNode.unfocus();
              }
            },
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(getProportionateScreenWidth(28)),
                topRight: Radius.circular(getProportionateScreenWidth(28)),
              ),
            child: Column(
              children: [
                // Content that can also drive the sheet
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: (_) {
                    if (widget.searchFocusNode.hasFocus) {
                      widget.searchFocusNode.unfocus();
                    }
                  },
                  onVerticalDragUpdate: (details) {
                    final screenHeight = MediaQuery.of(context).size.height;
                    final delta = details.primaryDelta! / screenHeight;
                    final currentSize = widget.controller.size;
                    final newSize = (currentSize - delta).clamp(0.5, 0.92);
                    widget.controller.jumpTo(newSize);
                  },
                  onVerticalDragEnd: (details) {
                    final currentSize = widget.controller.size;
                    final velocity = details.primaryVelocity!;
                    if (velocity < -500 || (velocity <= 0 && currentSize > 0.45)) {
                      widget.controller.animateTo(0.92, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
                    } else if (velocity > 500 || (velocity >= 0 && currentSize <= 0.45)) {
                      widget.controller.animateTo(0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
                    }
                  },
                  child: Column(
                    children: [
                      _buildDragHandle(context),
                      _buildSearchBar(),
                      SizedBox(height: getProportionateScreenHeight(16)),
                      SizedBox(
                        height: getProportionateScreenHeight(28),
                        child: _buildChipTabBar(),
                      ),
                      SizedBox(height: getProportionateScreenHeight(8)),
                    ],
                  ),
                ),

                // Tab Content (Optimized with ValueListenableBuilder for search)
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: widget.searchQuery,
                    builder: (context, query, _) {
                      return _buildTabContent(scrollController, query);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenHeight(34),
      child: Center(
        child: Container(
          width: getProportionateScreenWidth(40),
          height: getProportionateScreenHeight(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: getProportionateScreenHeight(40),
              padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
                border: Border.all(color: Colors.black.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                   Icon(Icons.search_rounded, color: Colors.black.withOpacity(0.4), size: 20),
                   SizedBox(width: getProportionateScreenWidth(8)),
                   Expanded(
                     child: TextField(
                       controller: widget.searchController,
                       focusNode: widget.searchFocusNode,
                       onTapOutside: (_) => widget.searchFocusNode.unfocus(),
                       style: TextStyle(fontFamily: 'DMSans', 
                         fontSize: getProportionateScreenWidth(14),
                         color: Colors.black,
                       ),
                       decoration: InputDecoration(
                         isDense: true,
                         contentPadding: EdgeInsets.zero,
                         hintText: "search subscriptions...",
                         hintStyle: TextStyle(fontFamily: 'DMSans', 
                           color: Colors.black.withOpacity(0.4),
                           fontSize: getProportionateScreenWidth(12),
                         ),
                         border: InputBorder.none,
                         enabledBorder: InputBorder.none,
                         focusedBorder: InputBorder.none,
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(12)),
          Container(
            width: getProportionateScreenWidth(40),
            height: getProportionateScreenHeight(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: Icon(Icons.tune_rounded, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildChipTabBar() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
      itemCount: _tabs.length,
      separatorBuilder: (context, index) => SizedBox(width: getProportionateScreenWidth(16)),
      itemBuilder: (context, index) {
        return ZeyroTapDetector(eventName: 'recurring_dues_sheet_tab_${_tabs[index].toLowerCase().replaceAll(" ", "_")}_selected', 
          onTap: () {
            if (widget.searchFocusNode.hasFocus) {
              widget.searchFocusNode.unfocus();
            }
            widget.tabController.animateTo(index);
          },
          child: AnimatedBuilder(
            animation: widget.tabController.animation!,
            builder: (context, _) {
              final bool isSelected = (widget.tabController.animation?.value.round() ?? widget.tabController.index) == index;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(8), vertical: 0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(getProportionateScreenWidth(12)),
                  border: isSelected ? null : Border.all(color: Colors.black.withOpacity(0.1)),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(12),
                    color: isSelected ? Colors.white : Colors.black.withOpacity(0.6),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabContent(ScrollController scrollController, String query) {
    final filtered = _getFilteredPayments(query);

    return AnimatedBuilder(
      animation: widget.tabController,
      builder: (context, child) {
        final currentIndex = widget.tabController.index;
        
        return TabBarView(
          controller: widget.tabController,
          children: [
            ActiveTab(
              currentMonth: widget.currentMonth,
              payments: filtered.where((p) {
                if (p['status'].toString().toLowerCase() != 'active') return false;
                final type = p['type'].toString().toLowerCase();
                if (type == 'monthly') return true;
                if (type == 'yearly') {
                  final int? dueMonth = p['month'] as int?;
                  return dueMonth == widget.currentMonth.month;
                }
                return false;
              }).toList(),
              onStatusChanged: widget.onStatusChanged,
              scrollController: currentIndex == 0 ? scrollController : null,
            ),
            CanceledTab(
              currentMonth: widget.currentMonth,
              payments: filtered.where((p) => p['status'].toString().toLowerCase() == 'paused').toList(),
              onStatusChanged: widget.onStatusChanged,
              scrollController: currentIndex == 1 ? scrollController : null,
            ),
            TrialsTab(
              currentMonth: widget.currentMonth,
              payments: filtered.where((p) => p['type'].toString().toLowerCase() == 'trial').toList(),
              onStatusChanged: widget.onStatusChanged,
              scrollController: currentIndex == 2 ? scrollController : null,
            ),
            AllTab(
              currentMonth: widget.currentMonth,
              payments: [...filtered]..sort((a, b) {
                final sA = a['status']?.toString().toLowerCase() ?? 'active';
                final sB = b['status']?.toString().toLowerCase() ?? 'active';
                if (sA == 'active' && sB != 'active') return -1;
                if (sA != 'active' && sB == 'active') return 1;
                return 0;
              }),
              onStatusChanged: widget.onStatusChanged,
              scrollController: currentIndex == 3 ? scrollController : null,
            ),
          ],
        );
      },
    );
  }
}
