import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/learning_module.dart';
import '../../models/chapter_models.dart';
import '../../models/mock_chapters.dart';
import '../../services/learning_progress_service.dart';

class ChapterListScreen extends StatelessWidget {
  final LearningModule module;
  final String level;

  const ChapterListScreen({
    super.key,
    required this.module,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 240,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E40AF),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Module ${module.id} • $level',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
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
          child: AnimatedBuilder(
            animation: LearningProgressService.instance,
            builder: (context, child) {
              final chapters = getMockChapters(module.id, level);
              final levelProgress = LearningProgressService.instance
                  .getLevelProgress(chapters);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _buildHeader(levelProgress),
                  ),
                  const SizedBox(height: 32),

                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 500),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      scrollDirection: Axis.horizontal,
                      itemCount: chapters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        return GestureDetector(
                          onTap: () {
                            context.push(
                              '/learnings/chapter-reader',
                              extra: {
                                'module': module,
                                'chapter': chapter,
                                'allChapters': chapters,
                              },
                            );
                          },
                          child: _buildChapterCard(context, chapter),
                        );
                      },
                    ),
                  ),
                ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int progressPercent) {
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
              child: Container(color: module.themeColor.withOpacity(0.12)),
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProgress(progressPercent),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'To fully complete this level, read all chapters and attempt all questions',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgress(int percent) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent / 100.0,
            strokeWidth: 3,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  percent.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
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

  Widget _buildChapterCard(BuildContext context, Chapter chapter) {
    // Width is 80% of screen to allow peeking next card
    final cardWidth = MediaQuery.sizeOf(context).width > 800
        ? 400.0 // Fixed max width on web/tablet
        : MediaQuery.sizeOf(context).width * 0.85;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration Placeholder Area
          AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF1F5F9), // Soft placeholder background
              child: chapter.imagePath != null
                  ? Image.asset(
                      chapter.imagePath!,
                      fit: BoxFit.contain,
                    )
                  : Stack(
                    children: [
                      // Abstract background shapes
                      Positioned(
                        top: 20,
                        left: 30,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: module.themeColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        right: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: module.themeColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Center Icon
                      Center(
                        child: Icon(
                          chapter.icon,
                          size: 64,
                          color: module.themeColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
            ),
          ),

          // Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      chapter.description,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chapter.readTime,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        '${chapter.cardsCount} cards',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
