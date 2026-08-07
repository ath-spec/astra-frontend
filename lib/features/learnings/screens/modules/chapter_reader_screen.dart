import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/learning_module.dart';
import '../../models/chapter_models.dart';
import '../../services/learning_progress_service.dart';

class ChapterReaderScreen extends StatefulWidget {
  final LearningModule module;
  final Chapter chapter;
  final List<Chapter> allChapters;

  const ChapterReaderScreen({
    super.key,
    required this.module,
    required this.chapter,
    required this.allChapters,
  });

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  
  bool _showSlider = false;
  double _textScale = 1.0;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markCurrentPageComplete();
    });
  }

  void _markCurrentPageComplete() {
    if (widget.chapter.pages.isNotEmpty) {
      final page = widget.chapter.pages[_currentPageIndex];
      LearningProgressService.instance.markPageComplete(widget.chapter.id, page.id);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goToNextPage() {
    if (_currentPageIndex < widget.chapter.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showSettingsMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              bottom: 80,
              left: 24,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chapters Button
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showChaptersBottomSheet(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.vertical_split_rounded,
                                color: const Color(0xFF2563EB),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Chapters',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(height: 1, color: _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      
                      // Font Size Controls
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_textScale > 0.8) setState(() => _textScale -= 0.1);
                              },
                              child: Icon(Icons.remove, color: const Color(0xFF2563EB), size: 20),
                            ),
                            const SizedBox(width: 24),
                            Text(
                              'A',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: () {
                                if (_textScale < 1.5) setState(() => _textScale += 0.1);
                              },
                              child: Icon(Icons.add, color: const Color(0xFF2563EB), size: 20),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      
                      // Theme Toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDarkMode = !_isDarkMode;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 56,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedPositioned(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      left: _isDarkMode ? 24 : 2,
                                      top: 2,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                            size: 16,
                                            color: _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
      },
    );
  }

  void _showChaptersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Beginner Chapters',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: widget.allChapters.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 32,
                    color: _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final ch = widget.allChapters[index];
                    final isCurrent = ch.id == widget.chapter.id;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        if (!isCurrent) {
                          context.pushReplacement('/learnings/chapter-reader', extra: {
                            'module': widget.module,
                            'chapter': ch,
                            'allChapters': widget.allChapters,
                          });
                        }
                      },
                      child: Row(
                        children: [
                          if (isCurrent)
                            Container(
                              width: 4,
                              height: 24,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E), // Green marker
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              ch.title,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 16,
                                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                                color: isCurrent 
                                  ? (_isDarkMode ? Colors.white : const Color(0xFF0F172A))
                                  : (_isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final appBarIconColor = _isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF1E40AF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leadingWidth: 300,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.arrow_back_ios_new_rounded, color: appBarIconColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.chapter.title}',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Hide slider if user taps on screen body
                        if (_showSlider) setState(() => _showSlider = false);
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                          _markCurrentPageComplete();
                        },
                        itemCount: widget.chapter.pages.length,
                        itemBuilder: (context, index) {
                          return _buildPage(widget.chapter.pages[index]);
                        },
                      ),
                    ),
                  ),
                  _buildBottomNav(),
                ],
              ),
              
              // Slider Overlay
              if (_showSlider)
                Positioned(
                  bottom: 80, // Positioned above the bottom nav
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            activeTrackColor: const Color(0xFF2563EB),
                            inactiveTrackColor: _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            thumbColor: const Color(0xFF2563EB),
                            overlayColor: const Color(0xFF2563EB).withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: _currentPageIndex.toDouble(),
                            min: 0,
                            max: (widget.chapter.pages.length - 1).toDouble(),
                            divisions: (widget.chapter.pages.length - 1) > 0 ? widget.chapter.pages.length - 1 : 1,
                            onChanged: (value) {
                              final targetPage = value.round();
                              if (targetPage != _currentPageIndex) {
                                setState(() {
                                  _currentPageIndex = targetPage;
                                });
                                _pageController.jumpToPage(targetPage);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(ChapterPage page) {
    final titleColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = _isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -20,
                top: 0,
                bottom: 0,
                width: 56,
                child: Container(
                  color: widget.module.themeColor.withOpacity(0.12),
                ),
              ),
              Positioned(
                left: -20,
                top: 4,
                bottom: 4,
                width: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.module.themeColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              Text(
                page.title,
                textScaler: TextScaler.linear(_textScale),
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Image Placeholder
          if (page.imagePath != null || widget.chapter.imagePath != null)
            AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  page.imagePath ?? widget.chapter.imagePath!,
                  fit: BoxFit.contain,
                ),
              ),
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.module.themeColor.withOpacity(_isDarkMode ? 0.3 : 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      widget.chapter.icon,
                      size: 64,
                      color: widget.module.themeColor.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
          
          // Content
          ...page.contents.map((content) {
            if (content is ChapterTextContent) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  content.text,
                  textScaler: TextScaler.linear(_textScale),
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: bodyColor,
                    height: 1.6,
                  ),
                ),
              );
            } else if (content is ChapterTableContent) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildTable(content),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTable(ChapterTableContent tableContent) {
    final borderColor = _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: borderColor, width: 1),
        ),
        children: [
          // Header Row
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
            ),
            children: tableContent.headers.map((header) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(
                  header,
                  textScaler: TextScaler.linear(_textScale),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
          // Data Rows
          ...tableContent.rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final isAlternate = index % 2 != 0;
            
            final rowColor = _isDarkMode
                ? (isAlternate ? const Color(0xFF0F172A) : const Color(0xFF1E293B))
                : (isAlternate ? const Color(0xFFF8FAFC) : Colors.white);
            
            final cellColor = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF334155);

            return TableRow(
              decoration: BoxDecoration(
                color: rowColor,
              ),
              children: row.map((cell) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(
                    cell,
                    textScaler: TextScaler.linear(_textScale),
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: cellColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final totalPages = widget.chapter.pages.length;
    
    final bgColor = _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = _isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final iconColor = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final centerPillColor = _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final arrowColor = _isDarkMode ? Colors.white : const Color(0xFF334155);
    final arrowDisabledColor = _isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor.withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 3-dot menu
          GestureDetector(
            onTap: () => _showSettingsMenu(context),
            child: Icon(Icons.more_vert_rounded, color: iconColor, size: 24),
          ),
          
          // Center Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: centerPillColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _goToPreviousPage,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 16,
                      color: _currentPageIndex > 0 ? arrowColor : arrowDisabledColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (totalPages > 1) {
                      setState(() => _showSlider = !_showSlider);
                    }
                  },
                  child: Text(
                    '${_currentPageIndex + 1}/$totalPages',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _goToNextPage,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: _currentPageIndex < totalPages - 1 ? arrowColor : arrowDisabledColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bookmark
          Icon(Icons.bookmark_border_rounded, color: iconColor, size: 24),
        ],
      ),
    );
  }
}
