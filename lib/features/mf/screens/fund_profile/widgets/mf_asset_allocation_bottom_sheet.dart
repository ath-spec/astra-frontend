import 'package:flutter/material.dart';
import '../../../../../core/models/fund_asset_allocation_data.dart';

class MfAssetAllocationBottomSheet extends StatefulWidget {
  final AssetAllocationData data;

  const MfAssetAllocationBottomSheet({super.key, required this.data});

  @override
  State<MfAssetAllocationBottomSheet> createState() => _MfAssetAllocationBottomSheetState();
}

class _MfAssetAllocationBottomSheetState extends State<MfAssetAllocationBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [];
    if (widget.data.equity != null) _tabs.add('Equity');
    if (widget.data.debt != null) _tabs.add('Debt');
    if (widget.data.others != null) _tabs.add('Others');

    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Asset Allocation',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'as of 30th Jul \'26',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Custom Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.only(right: 32),
              indicatorColor: const Color(0xFF0F172A),
              indicatorWeight: 2,
              dividerColor: Colors.transparent,
              tabs: _tabs.map((tabName) {
                return Tab(
                  child: _buildTabHeader(tabName),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tabName) {
                if (tabName == 'Equity') return _EquityView(data: widget.data.equity!);
                if (tabName == 'Debt') return _DebtView(data: widget.data.debt!);
                if (tabName == 'Others') return _OthersView(data: widget.data.others!);
                return const SizedBox();
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(String title) {
    Color squareColor = Colors.grey;
    String value = '';
    
    if (title == 'Equity' && widget.data.equity != null) {
      squareColor = const Color(0xFF3B82F6);
      value = '${widget.data.equity!.totalPercentage}%';
    } else if (title == 'Debt' && widget.data.debt != null) {
      squareColor = const Color(0xFF8B5CF6);
      value = '${widget.data.debt!.totalPercentage}%';
    } else if (title == 'Others' && widget.data.others != null) {
      squareColor = const Color(0xFFE11D48);
      value = '${widget.data.others!.totalPercentage}%';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: squareColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

class _EquityView extends StatefulWidget {
  final EquityAllocationData data;
  const _EquityView({required this.data});

  @override
  State<_EquityView> createState() => _EquityViewState();
}

class _EquityViewState extends State<_EquityView> {
  int _selectedDistTabIndex = 0; // 0 for Sectors, 1 for Holdings
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    List<DistributionItem> currentList = _selectedDistTabIndex == 0 ? widget.data.sectors : widget.data.holdings;
    List<DistributionItem> displayList = _showAll ? currentList : currentList.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Equity Market Cap Allocation',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          
          // Segmented Bar
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  Expanded(flex: (widget.data.largeCapPercentage * 100).toInt(), child: Container(color: const Color(0xFF3B82F6))),
                  Expanded(flex: (widget.data.midCapPercentage * 100).toInt(), child: Container(color: const Color(0xFF8B5CF6))),
                  Expanded(flex: (widget.data.smallCapPercentage * 100).toInt(), child: Container(color: const Color(0xFFE11D48))),
                ],
              ),
            ),
          ),

          
          const SizedBox(height: 16),
          _buildLegendRow(const Color(0xFF3B82F6), 'Large Cap', '${widget.data.largeCapPercentage}%'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
          _buildLegendRow(const Color(0xFF8B5CF6), 'Mid Cap', '${widget.data.midCapPercentage}%'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
          _buildLegendRow(const Color(0xFFE11D48), 'Small Cap', '${widget.data.smallCapPercentage}%'),
          
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 32),
          
          const Text(
            'Distribution',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          // Dist Tabs
          Row(
            children: [
              _buildPillTab('SECTORS', 0),
              const SizedBox(width: 8),
              _buildPillTab('HOLDINGS', 1),
            ],
          ),
          const SizedBox(height: 24),
          
          // List
          ...displayList.map((item) => _buildDistributionItem(item, const Color(0xFF8B5CF6))),
          
          if (!_showAll && currentList.length > 5)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAll = true;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Show more',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF0F172A)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildPillTab(String title, int index) {
    bool isSelected = _selectedDistTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDistTabIndex = index;
          _showAll = false;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionItem(DistributionItem item, Color barColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(item.icon, size: 20, color: const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ),
                        Text(
                          '${item.percentage.toStringAsFixed(2)}%',
                          style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: item.icon != null ? 52.0 : 0.0),
            child: Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (item.percentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtView extends StatefulWidget {
  final DebtAllocationData data;
  const _DebtView({required this.data});

  @override
  State<_DebtView> createState() => _DebtViewState();
}

class _DebtViewState extends State<_DebtView> {
  int _selectedDistTabIndex = 0;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    List<DistributionItem> currentList = _selectedDistTabIndex == 0 ? widget.data.sectors : widget.data.holdings;
    List<DistributionItem> displayList = _showAll ? currentList : currentList.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credit Quality Split',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          
          // Simplified segmented bar for Debt (just primary color for now)
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          
          const SizedBox(height: 16),
          ...widget.data.creditQuality.map((cq) => Column(
            children: [
              _buildLegendRow(const Color(0xFF3B82F6), cq.title, '${cq.percentage}%'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
            ],
          )).toList(),
          
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 32),
          
          const Text(
            'Distribution',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildPillTab('SECTORS', 0),
              const SizedBox(width: 8),
              _buildPillTab('HOLDINGS', 1),
            ],
          ),
          const SizedBox(height: 24),
          
          ...displayList.map((item) => _buildDistributionItem(item, const Color(0xFF8B5CF6))),
          
          if (!_showAll && currentList.length > 5)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAll = true;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Show more',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF0F172A)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildPillTab(String title, int index) {
    bool isSelected = _selectedDistTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDistTabIndex = index;
          _showAll = false;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionItem(DistributionItem item, Color barColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(item.icon, size: 20, color: const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ),
                        Text(
                          '${item.percentage.toStringAsFixed(2)}%',
                          style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: item.icon != null ? 52.0 : 0.0),
            child: Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (item.percentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OthersView extends StatefulWidget {
  final OtherAllocationData data;
  const _OthersView({required this.data});

  @override
  State<_OthersView> createState() => _OthersViewState();
}

class _OthersViewState extends State<_OthersView> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    List<DistributionItem> currentList = widget.data.holdings;
    List<DistributionItem> displayList = _showAll ? currentList : currentList.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Other Allocation',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4E5), // pale greenish as in screenshot
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 24),
          
          ...widget.data.otherAllocation.map((oa) => Column(
            children: [
              _buildLegendRow(const Color(0xFFF3F4E5), oa.title, '${oa.percentage}%'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
            ],
          )).toList(),
          
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 32),
          
          const Text(
            'Distribution',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildPillTab('HOLDINGS', true),
            ],
          ),
          const SizedBox(height: 24),
          
          ...displayList.map((item) => _buildDistributionItem(item, const Color(0xFF8B5CF6))),
          
          if (!_showAll && currentList.length > 5)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showAll = true;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Show more',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF0F172A)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildPillTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0F172A) : Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildDistributionItem(DistributionItem item, Color barColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(item.icon, size: 20, color: const Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ),
                        Text(
                          '${item.percentage.toStringAsFixed(2)}%',
                          style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: item.icon != null ? 52.0 : 0.0),
            child: Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (item.percentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
