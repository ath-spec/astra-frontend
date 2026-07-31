import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/recurring_calendar_widget.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/recurring_dues_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/yearly_calendar_view.dart';
import 'package:astra_frontend/features/recurring/presentation/screens/add_recurring_screen.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/day_payments_popup.dart';
import 'package:astra_frontend/features/recurring/widgets/noise_cache.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class RecurringControlScreen extends StatefulWidget {
  const RecurringControlScreen({super.key});

  @override
  State<RecurringControlScreen> createState() => _RecurringControlScreenState();
}

class _RecurringControlScreenState extends State<RecurringControlScreen>
    with TickerProviderStateMixin {
  bool _isYearlyView = false;
  DateTime _selectedDate = DateTime.now();
  ScrollController _yearlyScrollController = ScrollController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  
  Uint8List? _noiseImageBytes;

  // Tab and Search State for the Bottom Sheet (Elevated for back-gesture and focus)
  late final TabController _tabController;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>("");

  // Lifted state for payments to handle session-wide cancellations
  late List<Map<String, dynamic>> _payments;
  
  // State for Day Payments Popup (screen-level overlay)
  int? _popupDate;
  List<Map<String, dynamic>>? _popupPayments;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('recurring_control_screen');
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      _searchQuery.value = _searchController.text;
    });
    _searchFocusNode.addListener(_onSearchFocusChange);

    // Use cached noise bytes to avoid repeated base64 decodes/native allocations
    try {
      _noiseImageBytes = NoiseCache.bytes;
    } catch (e) {
      debugPrint('Error getting cached noise texture: $e');
    }

    _payments = [
      {
        'id': '1',
        'day': 11,
        'name': 'Spotify India Pvt Ltd',
        'type': 'Monthly',
        'amount': 99.0,
        'logoAsset': 'lib/core/images/spotify-icon.svg',
        'isDark': true,
        'backgroundColor': const Color(0xFF1DB954),
        'dotColor': const Color(0xFFC0D72F),
        'status': 'active',
        'bank': 'HSBC •• 6006',
      },
      {
        'id': '2',
        'day': 11,
        'name': 'Notion',
        'type': 'Monthly',
        'amount': 399.0,
        'logoAsset': 'lib/core/images/Notion-logo.svg',
        'isDark': false,
        'backgroundColor': Colors.white,
        'dotColor': const Color(0xFFE5803E),
        'status': 'active',
        'bank': 'Zeyro Bank •• 1234',
      },
      {
        'id': '3',
        'day': 17,
        'name': 'Perplexity',
        'type': 'Monthly',
        'amount': 1699.0,
        'logoAsset': 'lib/core/images/Perplexity_Black_0.svg',
        'isDark': true,
        'backgroundColor': Colors.black87,
        'dotColor': const Color(0xFFC0D72F),
        'status': 'active',
        'bank': 'HDFC •• 4455',
      },
      {
        'id': '4',
        'day': 22,
        'name': 'Netflix',
        'type': 'Monthly',
        'amount': 649.0,
        'logoAsset': 'lib/core/images/Netflix_icon.svg',
        'isDark': true,
        'backgroundColor': Colors.black,
        'dotColor': const Color(0xFFE5803E),
        'status': 'active',
        'bank': 'ICICI •• 7788',
      },
      {
        'id': '5',
        'day': 11,
        'name': 'YouTube Premium',
        'type': 'Monthly',
        'amount': 79.0,
        'logoAsset': 'lib/core/images/youtube-icon.svg',
        'isDark': false,
        'backgroundColor': Colors.white,
        'dotColor': const Color(0xFFFF0000),
        'status': 'active',
        'bank': 'HDFC •• 4455',
      },
      {
        'id': '6',
        'day': 11,
        'name': 'Claude AI',
        'type': 'Monthly',
        'amount': 1699.0,
        'logoAsset': 'lib/core/images/Claude_AI_symbol.svg',
        'isDark': true,
        'backgroundColor': const Color(0xFFD97757),
        'dotColor': const Color(0xFFD97757),
        'status': 'active',
        'bank': 'Zeyro Bank •• 4455',
      },
      {
        'id': '7',
        'day': 11,
        'name': 'Disney+ Hotstar',
        'type': 'Yearly',
        'amount': 1499.0,
        'logoAsset': 'lib/core/images/Disney.svg',
        'isDark': true,
        'backgroundColor': const Color(0xFF001524),
        'dotColor': const Color(0xFF030B17),
        'status': 'active',
        'bank': 'ICICI •• 7788',
      },
      {
        'id': '8',
        'day': 19,
        'month': 5,
        'name': 'Canva',
        'type': 'Yearly',
        'amount': 8000.0,
        'logoAsset': 'lib/core/images/canva.svg',
        'isDark': false,
        'backgroundColor': const Color(0xFF00C4CC),
        'dotColor': const Color(0xFF00C4CC),
        'status': 'active',
        'bank': 'HDFC •• 4455',
      },
    ];
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      if (_sheetController.isAttached && _sheetController.size < 0.9) {
        _sheetController.animateTo(
          0.92,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _onStatusChanged(String id, String newStatus, {DateTime? pauseUntil}) {
    setState(() {
      final index = _payments.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        _payments[index]['status'] = newStatus;
        if (pauseUntil != null) {
          _payments[index]['pauseUntil'] = pauseUntil;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _searchQuery.dispose();
    _yearlyScrollController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _onTodayPressed() {
    final now = DateTime.now();

    if (_isYearlyView) {
      final bool isAtTop =
          _yearlyScrollController.hasClients &&
          _yearlyScrollController.offset < 50;
      bool isCurrentYear = _selectedDate.year == now.year;

      if (!isCurrentYear || !isAtTop) {
        setState(() {
          _selectedDate = DateTime(now.year, _selectedDate.month);
        });
        
        final double sectionHeight = YearlyCalendarViewWidget.calculateYearSectionHeight(context);
        final int startYear = YearlyCalendarViewWidget.getStartYear();
        final int targetIndex = now.year - startYear;
        
        _yearlyScrollController.animateTo(
          sectionHeight * targetIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      } else {
        setState(() {
          _isYearlyView = false;
        });
      }
    } else {
      setState(() {
        _selectedDate = now;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListenableBuilder(
        listenable: _sheetController,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: _isYearlyView ? Colors.white : Colors.transparent,
          child: Stack(
            children: [
              // 1. Premium Gradient Background & Grain Texture Overlay
              Positioned.fill(
                child: RepaintBoundary(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: _isYearlyView ? 0.0 : 1.0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.0, 0.65],
                                colors: [
                                  Color(0xFF131D2F), // Deep Navy
                                  Color(0xFFE89A84), // Soft Peach
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: _isYearlyView ? 0.0 : 0.3, // Significantly more visible grain
                          child: _noiseImageBytes != null
                              ? Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(_noiseImageBytes!),
                                      fit: BoxFit.none,
                                      repeat: ImageRepeat.repeat,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Main Content with background drag detection
              RepaintBoundary(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _searchFocusNode.unfocus();
                    if (_isYearlyView) {
                      setState(() => _isYearlyView = false);
                    } else if (_sheetController.isAttached && _sheetController.size > 0.51) {
                      _sheetController.animateTo(
                        0.5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  onVerticalDragUpdate: (details) {
                    if (_isYearlyView) return;

                    final screenHeight = MediaQuery.of(context).size.height;
                    final delta = details.primaryDelta! / screenHeight;
                    final currentSize = _sheetController.size;

                    // Drive the sheet from anywhere on the background
                    if ((details.primaryDelta! < 0 && currentSize < 0.92) ||
                        (details.primaryDelta! > 0 && currentSize > 0.5)) {
                      final newSize = (currentSize - delta).clamp(0.5, 0.92);
                      _sheetController.jumpTo(newSize);
                    }
                  },
                  onVerticalDragEnd: (details) {
                    if (_isYearlyView) return;
                    final currentSize = _sheetController.size;
                    final velocity = details.primaryVelocity!;

                    if (velocity < -500 || (velocity <= 0 && currentSize > 0.7)) {
                      _sheetController.animateTo(
                        0.92,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    } else if (velocity > 500 ||
                        (velocity >= 0 && currentSize <= 0.7)) {
                      _sheetController.animateTo(
                        0.5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  child: ListenableBuilder(
                    listenable: _sheetController,
                    builder: (context, child) {
                      final double size = _sheetController.isAttached ? _sheetController.size : 0.5;
                      final double opacity = ((0.92 - size) / 0.42).clamp(0.0, 1.0);
                      final double overlayIntensity = ((size - 0.5) / 0.42).clamp(0.0, 0.4);

                      return Stack(
                        children: [
                          Opacity(
                            opacity: opacity,
                            child: child,
                          ),
                          if (size > 0.5)
                            IgnorePointer(
                              child: Container(
                                color: Colors.black.withValues(alpha: overlayIntensity),
                              ),
                            ),
                        ],
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: topPadding + getProportionateScreenHeight(8)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ZeyroIconButton(eventName: 'recurring_control_screen_back_tapped', 
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: _isYearlyView ? Colors.black : Colors.white,
                                  size: getProportionateScreenWidth(20),
                                ),
                                onPressed: () {
                                  if (_isYearlyView) {
                                    setState(() => _isYearlyView = false);
                                  } else {
                                    context.pop();
                                  }
                                },
                              ),
                              Expanded(
                                child: ZeyroTapDetector(eventName: 'recurring_control_screen_calendar_header_tapped', 
                                  onTap: () {
                                    if (_isYearlyView) {
                                      setState(() => _isYearlyView = false);
                                    } else if (_sheetController.isAttached && _sheetController.size < 0.55) {
                                      setState(() => _isYearlyView = true);
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat('MMMM yyyy').format(_selectedDate).toLowerCase(),
                                        style: TextStyle(fontFamily: 'DMSans', 
                                          fontSize: getProportionateScreenWidth(18),
                                          fontWeight: FontWeight.w600,
                                          color: _isYearlyView ? Colors.black : Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: getProportionateScreenWidth(4)),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: _isYearlyView ? Colors.black : Colors.white,
                                        size: getProportionateScreenWidth(20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!_isYearlyView)
                                ZeyroTapDetector(eventName: 'recurring_control_screen_add_tapped', 
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddRecurringScreen()),
                                  ),
                                  child: Container(
                                    width: getProportionateScreenWidth(30),
                                    height: getProportionateScreenWidth(30),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(getProportionateScreenWidth(11)),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: getProportionateScreenWidth(20),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(width: getProportionateScreenWidth(36 + 8)),
                              SizedBox(width: getProportionateScreenWidth(8)),
                            ],
                          ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(0)),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            reverseDuration: const Duration(milliseconds: 250),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              final scaleAnimation = Tween<double>(
                                begin: (child.key == const ValueKey('yearly')) ? 1.03 : 0.97,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: const Cubic(0.23, 1, 0.32, 1),
                                ),
                              );
                              final blurAnimation = Tween<double>(begin: 4.0, end: 0.0).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                ),
                              );
                              return FadeTransition(
                                opacity: animation,
                                child: AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, childWidget) {
                                    return ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: blurAnimation.value,
                                        sigmaY: blurAnimation.value,
                                        tileMode: TileMode.decal,
                                      ),
                                      child: ScaleTransition(
                                        scale: scaleAnimation,
                                        child: childWidget,
                                      ),
                                    );
                                  },
                                  child: child,
                                ),
                              );
                            },
                            child: _isYearlyView
                                ? YearlyCalendarViewWidget(
                                    key: const ValueKey('yearly'),
                                    initialDate: _selectedDate,
                                    scrollController: _yearlyScrollController,
                                    onMonthSelected: (DateTime newMonth) {
                                      setState(() {
                                        _selectedDate = newMonth;
                                        _isYearlyView = false;
                                      });
                                    },
                                  )
                                : Align(
                                    alignment: Alignment.topCenter,
                                    child: RecurringCalendarWidget(
                                      key: ValueKey('monthly_${_selectedDate.year}_${_selectedDate.month}'),
                                      currentMonth: _selectedDate,
                                      payments: _payments,
                                      onMonthChanged: (newMonth) {
                                        setState(() {
                                          _selectedDate = newMonth;
                                        });
                                      },
                                      onHeaderTapped: () {
                                        final double sectionHeight = YearlyCalendarViewWidget.calculateYearSectionHeight(context);
                                        final int targetIndex = _selectedDate.year - YearlyCalendarViewWidget.getStartYear();
                                        
                                        final oldController = _yearlyScrollController;
                                        _yearlyScrollController = ScrollController(
                                          initialScrollOffset: sectionHeight * targetIndex,
                                        );
                                        oldController.dispose();

                                        setState(() {
                                          _isYearlyView = true;
                                        });
                                      },
                                      onDaySelected: (date, payments) {
                                        setState(() {
                                          _popupDate = date;
                                          _popupPayments = payments;
                                        });
                                      },
                                    ),
                                  ),
                          ),
                        ),
                        if (!_isYearlyView)
                          SizedBox(height: getProportionateScreenHeight(100)),
                      ],
                    ),
                  ),
                ),
              ),

              // Draggable Dues Sheet
              Offstage(
                offstage: _isYearlyView,
                child: RecurringDuesSheet(
                  key: const ValueKey('dues_sheet'),
                  currentMonth: _selectedDate,
                  controller: _sheetController,
                  tabController: _tabController,
                  searchFocusNode: _searchFocusNode,
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  payments: _payments,
                  onStatusChanged: _onStatusChanged,
                ),
              ),

              // Floating Today Pill Overlay
              if (_isYearlyView)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + getProportionateScreenHeight(20),
                  left: getProportionateScreenWidth(24),
                  child: _buildTodayPill(),
                ),

              // Day Payments Popup Overlay
              if (_popupDate != null && _popupPayments != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      AnalyticsService.instance.logEvent('recurring_control_screen_popup_overlay_tapped');
                      setState(() {
                        _popupDate = null;
                        _popupPayments = null;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.02),
                          alignment: Alignment.center,
                          child: GestureDetector(
            onTap: () {},
                            child: DayPaymentsPopup(
                              date: _popupDate!,
                              payments: _popupPayments!,
                              onClose: () => setState(() {
                                _popupDate = null;
                                _popupPayments = null;
                              }),
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
        builder: (context, child) {
          final double sheetSize = _sheetController.isAttached ? _sheetController.size : 0.5;
          return PopScope(
            canPop: !_isYearlyView && sheetSize <= 0.51 && _tabController.index == 0 && !_searchFocusNode.hasFocus,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_isYearlyView) {
                setState(() => _isYearlyView = false);
              } else {
                bool handled = false;
                if (_tabController.index > 0 || _searchFocusNode.hasFocus) {
                  if (_tabController.index > 0) _tabController.animateTo(0);
                  if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
                  handled = true;
                } 
                if (!handled && _sheetController.isAttached && sheetSize > 0.51) {
                  _sheetController.animateTo(
                    0.5,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                  handled = true;
                }
              }
            },
            child: child!,
          );
        },
      ),
    );
  }

  Widget _buildTodayPill() {
    return ZeyroTapDetector(eventName: 'recurring_control_screen_today_tapped', 
      onTap: _onTodayPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(20),
              vertical: getProportionateScreenHeight(8),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
            ),
            child: Text(
              "today",
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(16),
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
