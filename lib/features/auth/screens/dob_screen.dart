import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DobScreen extends StatefulWidget {
  const DobScreen({super.key});

  @override
  State<DobScreen> createState() => _DobScreenState();
}

class _DobScreenState extends State<DobScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = 2001;

  final List<String> _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    
    // Years from 1950 to current year
    final currentYear = DateTime.now().year;
    final yearIndex = (currentYear - 1950) - (currentYear - _selectedYear);
    _yearController = FixedExtentScrollController(initialItem: yearIndex);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submit() {
    context.push('/aa-stocks-otp');
  }

  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}TH';
    }
    switch (number % 10) {
      case 1:
        return '${number}ST';
      case 2:
        return '${number}ND';
      case 3:
        return '${number}RD';
      default:
        return '${number}TH';
    }
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  String _getWeekdayName(DateTime date) {
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    return days[date.weekday - 1];
  }

  void _onDateChanged() {
    final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > daysInMonth) {
      setState(() {
        _selectedDay = daysInMonth;
      });
      _dayController.jumpToItem(daysInMonth - 1);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final age = DateTime.now().year - _selectedYear;
    final weekday = _getWeekdayName(selectedDate);
    final monthName = _months[_selectedMonth - 1];
    final ordinalDay = _getOrdinal(_selectedDay);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'YOU WERE BORN\nON THE $ordinalDay OF $monthName, $_selectedYear.',
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            height: 1.3,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Picker Section
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          child: Column(
                            children: [
                              // Headers
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
                                  color: Color(0xFFF9FAFB),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(child: Center(child: Text('DAY', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: Color(0xFF9CA3AF))))),
                                    Expanded(flex: 2, child: Center(child: Text('MONTH', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: Color(0xFF9CA3AF))))),
                                    Expanded(child: Center(child: Text('YEAR', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: Color(0xFF9CA3AF))))),
                                  ],
                                ),
                              ),
                              // Wheels
                              Expanded(
                                child: Stack(
                                  children: [
                                    // Selection Overlay Lines
                                    Center(
                                      child: Container(
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                                            bottom: BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                                          ),
                                          color: Color(0xFFF3F4F6),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Day Wheel
                                        Expanded(
                                          child: ListWheelScrollView.useDelegate(
                                            controller: _dayController,
                                            itemExtent: 48,
                                            perspective: 0.005,
                                            diameterRatio: 1.5,
                                            physics: const FixedExtentScrollPhysics(),
                                            onSelectedItemChanged: (index) {
                                              setState(() => _selectedDay = index + 1);
                                              _onDateChanged();
                                            },
                                            childDelegate: ListWheelChildBuilderDelegate(
                                              childCount: _getDaysInMonth(_selectedYear, _selectedMonth),
                                              builder: (context, index) {
                                                final day = index + 1;
                                                final isSelected = day == _selectedDay;
                                                return Center(
                                                  child: Text(
                                                    day.toString(),
                                                    style: TextStyle(
                                                      fontFamily: 'SpaceGrotesk',
                                                      fontSize: isSelected ? 24 : 18,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                      color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF).withValues(alpha: 0.5),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // Month Wheel
                                        Expanded(
                                          flex: 2,
                                          child: ListWheelScrollView.useDelegate(
                                            controller: _monthController,
                                            itemExtent: 48,
                                            perspective: 0.005,
                                            diameterRatio: 1.5,
                                            physics: const FixedExtentScrollPhysics(),
                                            onSelectedItemChanged: (index) {
                                              setState(() => _selectedMonth = index + 1);
                                              _onDateChanged();
                                            },
                                            childDelegate: ListWheelChildBuilderDelegate(
                                              childCount: 12,
                                              builder: (context, index) {
                                                final isSelected = (index + 1) == _selectedMonth;
                                                return Center(
                                                  child: Text(
                                                    _months[index],
                                                    style: TextStyle(
                                                      fontFamily: 'SpaceGrotesk',
                                                      fontSize: isSelected ? 24 : 18,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                      letterSpacing: 1.0,
                                                      color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF).withValues(alpha: 0.5),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // Year Wheel
                                        Expanded(
                                          child: ListWheelScrollView.useDelegate(
                                            controller: _yearController,
                                            itemExtent: 48,
                                            perspective: 0.005,
                                            diameterRatio: 1.5,
                                            physics: const FixedExtentScrollPhysics(),
                                            onSelectedItemChanged: (index) {
                                              setState(() => _selectedYear = 1950 + index);
                                              _onDateChanged();
                                            },
                                            childDelegate: ListWheelChildBuilderDelegate(
                                              childCount: DateTime.now().year - 1950 + 1,
                                              builder: (context, index) {
                                                final year = 1950 + index;
                                                final isSelected = year == _selectedYear;
                                                return Center(
                                                  child: Text(
                                                    year.toString(),
                                                    style: TextStyle(
                                                      fontFamily: 'SpaceGrotesk',
                                                      fontSize: isSelected ? 24 : 18,
                                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                      color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF).withValues(alpha: 0.5),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                        // Subtext (Age and weekday)
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Color(0xFF9CA3AF),
                              ),
                              children: [
                                TextSpan(
                                  text: '$age YEARS',
                                  style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800),
                                ),
                                const TextSpan(text: ' · BORN ON A '),
                                TextSpan(
                                  text: weekday,
                                  style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: GestureDetector(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    onTap: _submit,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFF5BA1F7),
                              Color(0xFF031E6B),
                              Color(0xFF241714),
                            ],
                            stops: [0.0, 0.25, 0.7, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Positioned(
                              right: 20,
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
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
