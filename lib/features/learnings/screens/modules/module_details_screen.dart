import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/learning_module.dart';
import '../../models/chapter_models.dart';
import '../../models/mock_chapters.dart';

class ModuleDetailsScreen extends StatelessWidget {
  final LearningModule module;

  const ModuleDetailsScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 120,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E40AF), size: 18),
              const SizedBox(width: 8),
              Text(
                'Module ${module.id}',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Text(
                  'हिन्दी',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.open_in_new_rounded, color: const Color(0xFF1E40AF).withOpacity(0.8), size: 16),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                _buildHeader(),
                const SizedBox(height: 40),
                
                // Chapter Levels
                Builder(
                  builder: (context) {
                    final beginnerChapters = getMockChapters(module.id, 'Beginner');
                    final intermediateChapters = getMockChapters(module.id, 'Intermediate');
                    final advanceChapters = getMockChapters(module.id, 'Advance');

                    int getReadTime(List<Chapter> chapters) {
                      return chapters.fold(0, (sum, ch) {
                        final parts = ch.readTime.split(' ');
                        return sum + (parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 10) : 10);
                      });
                    }

                    return Column(
                      children: [
                        ChapterLevelCard(
                          level: 'Beginner',
                          chapters: beginnerChapters.length,
                          readTimeMinutes: getReadTime(beginnerChapters),
                          progressPercent: module.id == 1 ? 18 : 0,
                          onTap: () => context.push('/chapter-list', extra: {'module': module, 'level': 'Beginner'}),
                        ),
                        const SizedBox(height: 24),
                        ChapterLevelCard(
                          level: 'Intermediate',
                          chapters: intermediateChapters.length,
                          readTimeMinutes: getReadTime(intermediateChapters),
                          progressPercent: 0,
                          onTap: () => context.push('/chapter-list', extra: {'module': module, 'level': 'Intermediate'}),
                        ),
                        const SizedBox(height: 24),
                        ChapterLevelCard(
                          level: 'Advance',
                          chapters: advanceChapters.length,
                          readTimeMinutes: getReadTime(advanceChapters),
                          progressPercent: 0,
                          onTap: () => context.push('/chapter-list', extra: {'module': module, 'level': 'Advance'}),
                        ),
                      ],
                    );
                  }
                ),
                
                const SizedBox(height: 40),
                // Locked assessment section
                _buildLockedAssessment(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Highlight block behind title
            Positioned(
              left: -20,
              top: 0,
              bottom: 0,
              width: 56,
              child: Container(
                color: module.themeColor.withOpacity(0.12),
              ),
            ),
            // Vertical bar
            Positioned(
              left: -20,
              top: 4,
              bottom: 4,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: module.themeColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
            Text(
              module.title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          module.description,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedAssessment() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lock Icon Container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF475569),
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete all the levels and unlock Module Assessment',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Learn more',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterLevelCard extends StatefulWidget {
  final String level;
  final int chapters;
  final int readTimeMinutes;
  final int progressPercent;
  final VoidCallback onTap;

  const ChapterLevelCard({
    super.key,
    required this.level,
    required this.chapters,
    required this.readTimeMinutes,
    required this.progressPercent,
    required this.onTap,
  });

  @override
  State<ChapterLevelCard> createState() => _ChapterLevelCardState();
}

class _ChapterLevelCardState extends State<ChapterLevelCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(top: 14), // Space for overlapping pill
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.chapters} Chapters • ${widget.readTimeMinutes} min read',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    _buildCircularProgress(),
                  ],
                ),
              ),
              // Overlapping Pill
              Positioned(
                top: -14,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    widget.level,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
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

  Widget _buildCircularProgress() {
    final hasProgress = widget.progressPercent > 0;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: hasProgress ? widget.progressPercent / 100 : 1.0,
            strokeWidth: 3,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(
              hasProgress ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
            ),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${widget.progressPercent < 10 ? '0${widget.progressPercent}' : widget.progressPercent}',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Text(
                  '%',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
