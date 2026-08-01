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
      'image': 'lib/core/images/house\.webp',
      'planTitle': 'Your House Goal Plan',
      'planSubtitle': '₹50 Lakhs • 7 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '3 Funds'},
        {'icon': Icons.lock_outline_rounded, 'title': 'Safe Instruments', 'subtitle': '1 Bond'},
        {'icon': Icons.apartment_rounded, 'title': 'Real Estate', 'subtitle': '1 REIT'},
      ],
      'expectedValue': '₹52.3 Lakhs',
      'probability': '68%',
    },
    {
      'title': 'Travel',
      'image': 'lib/core/images/travel\.webp',
      'planTitle': 'Your Travel Goal Plan',
      'planSubtitle': '₹5 Lakhs • 2 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '2 Funds'},
        {'icon': Icons.water_drop_outlined, 'title': 'Liquid Funds', 'subtitle': '1 Fund'},
      ],
      'expectedValue': '₹5.5 Lakhs',
      'probability': '85%',
    },
    {
      'title': 'Education',
      'image': 'lib/core/images/edu\.webp',
      'planTitle': 'Your Education Goal Plan',
      'planSubtitle': '₹25 Lakhs • 10 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '4 Funds'},
        {'icon': Icons.lock_outline_rounded, 'title': 'Safe Instruments', 'subtitle': '2 Bonds'},
      ],
      'expectedValue': '₹26.2 Lakhs',
      'probability': '75%',
    },
    {
      'title': 'Wedding',
      'image': 'lib/core/images/wed\.webp',
      'planTitle': 'Your Wedding Goal Plan',
      'planSubtitle': '₹30 Lakhs • 5 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '3 Funds'},
        {'icon': Icons.lock_outline_rounded, 'title': 'Safe Instruments', 'subtitle': '1 FD'},
      ],
      'expectedValue': '₹31.5 Lakhs',
      'probability': '70%',
    },
    {
      'title': 'Retirement',
      'image': 'lib/core/images/target.webp',
      'planTitle': 'Your Retirement Plan',
      'planSubtitle': '₹3.5 Crores • 25 Years',
      'items': [
        {'icon': Icons.pie_chart_outline_rounded, 'title': 'Recommended Funds', 'subtitle': '5 Funds'},
        {'icon': Icons.lock_outline_rounded, 'title': 'Safe Instruments', 'subtitle': '3 Bonds'},
        {'icon': Icons.apartment_rounded, 'title': 'Real Estate', 'subtitle': '2 REITs'},
      ],
      'expectedValue': '₹3.8 Crores',
      'probability': '60%',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedGoal = _goals[_selectedIndex];
    
    // Compute responsive scale for the massive target graphic
    final screenWidth = MediaQuery.sizeOf(context).width;
    final imageScale = screenWidth < 420 ? screenWidth / 420 : 1.0;
    final imageSize = 230.0 * imageScale;
    final rightOffset = -60.0 * imageScale;
    final topOffset = -150.0 * imageScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Goal Planning',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Row(
                children: const [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF0F172A),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Goal image chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: List.generate(_goals.length, (index) {
              final goal = _goals[index];
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: _buildGoalIcon(
                  index: index,
                  imagePath: goal['image'] as String,
                  title: goal['title'] as String,
                  isActive: _selectedIndex == index,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        // Plan card
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -300) {
              // Swipe left -> Next goal
              if (_selectedIndex < _goals.length - 1) {
                setState(() => _selectedIndex++);
              }
            } else if (velocity > 300) {
              // Swipe right -> Previous goal
              if (_selectedIndex > 0) {
                setState(() => _selectedIndex--);
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color.fromARGB(255, 218, 219, 220), // Slate 100
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titles
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedGoal['planTitle'] as String,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                      ],
                    ),
                    const SizedBox(height: 40), // Space for image to overlap upwards
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            children: List.generate(
                              (selectedGoal['items'] as List).length,
                              (index) {
                                final item = (selectedGoal['items'] as List)[index];
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: _buildPlanItem(
                                        icon: item['icon'] as IconData,
                                        title: item['title'] as String,
                                        subtitle: item['subtitle'] as String,
                                      ),
                                    ),
                                    if (index < (selectedGoal['items'] as List).length - 1)
                                      const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        // Target graphic — image version floating over border
                        Positioned(
                          right: rightOffset,
                          top: topOffset,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            reverseDuration: const Duration(milliseconds: 150),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                  reverseCurve: Curves.easeOutCubic,
                                ),
                                child: ScaleTransition(
                                  scale: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutBack, // Keep the bounce for enter
                                    reverseCurve: Curves.easeOutCubic, // Snappy exit, NO bounce (prevents overlap swell)
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              key: ValueKey(selectedGoal['image']),
                              width: imageSize,
                              height: imageSize,
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Image.asset(
                                    selectedGoal['image'] as String,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
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
                          Text(
                            selectedGoal['expectedValue'] as String,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
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
                          Text(
                            selectedGoal['probability'] as String,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Start SIP',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
       ),
      ],
    );
  }

  Widget _buildGoalIcon({
    required int index,
    required String imagePath,
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
          SizedBox(
            height: 100,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: isActive ? 100 : 80,
                height: isActive ? 100 : 80,
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.6,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF5BA1F7) : const Color(0xFF64748B),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Center(
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        ),
      ],
    );
  }
}
