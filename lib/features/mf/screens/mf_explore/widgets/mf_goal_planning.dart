import 'package:flutter/material.dart';

class MfGoalPlanning extends StatefulWidget {
  const MfGoalPlanning({super.key});

  @override
  State<MfGoalPlanning> createState() => _MfGoalPlanningState();
}

class _MfGoalPlanningState extends State<MfGoalPlanning> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'House',
      'icon': Icons.home_rounded,
      'planTitle': 'Your House Goal Plan',
      'planSubtitle': '₹50 Lakhs • 7 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '3 Funds'},
        {'icon': Icons.lock_outline_rounded, 'title': 'Safe Instruments', 'subtitle': '1 Bond'},
        {'icon': Icons.apartment_rounded, 'title': 'Real Estate', 'subtitle': '1 REIT'},
      ],
      'targetIcon': Icons.track_changes_rounded,
      'expectedValue': '₹52.3 Lakhs',
      'probability': '68%',
    },
    {
      'title': 'Travel',
      'icon': Icons.flight_takeoff_rounded,
      'planTitle': 'Your Travel Goal Plan',
      'planSubtitle': '₹5 Lakhs • 2 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '2 Funds'},
        {'icon': Icons.water_drop_outlined, 'title': 'Liquid Funds', 'subtitle': '1 Fund'},
      ],
      'targetIcon': Icons.flight_rounded,
      'expectedValue': '₹5.5 Lakhs',
      'probability': '85%',
    },
    {
      'title': 'Education',
      'icon': Icons.school_rounded,
      'planTitle': 'Your Education Goal Plan',
      'planSubtitle': '₹25 Lakhs • 10 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '4 Funds'},
        {'icon': Icons.lock_outline_rounded, 'title': 'Safe Instruments', 'subtitle': '2 Bonds'},
      ],
      'targetIcon': Icons.school_outlined,
      'expectedValue': '₹26.2 Lakhs',
      'probability': '75%',
    },
    {
      'title': 'Wedding',
      'icon': Icons.celebration_rounded,
      'planTitle': 'Your Wedding Goal Plan',
      'planSubtitle': '₹30 Lakhs • 5 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '3 Funds'},
        {'icon': Icons.lock_outline_rounded, 'title': 'Safe Instruments', 'subtitle': '1 FD'},
      ],
      'targetIcon': Icons.favorite_border_rounded,
      'expectedValue': '₹31.5 Lakhs',
      'probability': '70%',
    },
    {
      'title': 'Car',
      'icon': Icons.directions_car_rounded,
      'planTitle': 'Your Car Goal Plan',
      'planSubtitle': '₹15 Lakhs • 3 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '2 Funds'},
        {'icon': Icons.water_drop_outlined, 'title': 'Liquid Funds', 'subtitle': '1 Fund'},
      ],
      'targetIcon': Icons.time_to_leave_rounded,
      'expectedValue': '₹16.1 Lakhs',
      'probability': '80%',
    },
    {
      'title': 'Retirement',
      'icon': Icons.beach_access_rounded,
      'planTitle': 'Your Retirement Plan',
      'planSubtitle': '₹3.5 Crores • 25 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '5 Funds'},
        {'icon': Icons.lock_outline_rounded, 'title': 'Safe Instruments', 'subtitle': '3 Bonds'},
        {'icon': Icons.apartment_rounded, 'title': 'Real Estate', 'subtitle': '2 REITs'},
      ],
      'targetIcon': Icons.savings_outlined,
      'expectedValue': '₹3.8 Crores',
      'probability': '60%',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedGoal = _goals[_selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Goal Planning',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Goal icons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: List.generate(_goals.length, (index) {
              final goal = _goals[index];
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: _buildGoalIcon(
                  index: index,
                  icon: goal['icon'] as IconData,
                  title: goal['title'] as String,
                  isActive: _selectedIndex == index,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        // Plan card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF1F5F9), // Slate 100
            ),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
              // Header & Graphic
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        child: Column(
                          key: ValueKey(selectedGoal['title']),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedGoal['planTitle'] as String,
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedGoal['planSubtitle'] as String,
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...(selectedGoal['items'] as List<Map<String, dynamic>>).map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildPlanItem(
                                  icon: item['icon'] as IconData,
                                  title: item['title'] as String,
                                  subtitle: item['subtitle'] as String,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    // Target graphic
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                          child: child,
                        );
                      },
                      child: Container(
                        key: ValueKey(selectedGoal['targetIcon']),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Icon(
                            selectedGoal['targetIcon'] as IconData,
                            size: 32,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expected Value',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          layoutBuilder: (currentChild, previousChildren) => Stack(
                            alignment: Alignment.centerLeft,
                            children: [...previousChildren, if (currentChild != null) currentChild],
                          ),
                          child: Text(
                            selectedGoal['expectedValue'] as String,
                            key: ValueKey(selectedGoal['expectedValue']),
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Probability',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          layoutBuilder: (currentChild, previousChildren) => Stack(
                            alignment: Alignment.centerLeft,
                            children: [...previousChildren, if (currentChild != null) currentChild],
                          ),
                          child: Text(
                            selectedGoal['probability'] as String,
                            key: ValueKey(selectedGoal['probability']),
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Start SIP',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
         ),
        ),
      ],
    );
  }

  Widget _buildGoalIcon({
    required int index,
    required IconData icon,
    required String title,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isActive ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
                width: isActive ? 1.5 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF64748B),
            ),
            child: Text(title),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
