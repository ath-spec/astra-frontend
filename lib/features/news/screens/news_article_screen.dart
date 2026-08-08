import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/news_article.dart';

class NewsArticleScreen extends StatefulWidget {
  final String image;
  final List<String> tags;
  final String title;
  final String description;
  final String source;
  final String heroTag;

  const NewsArticleScreen({
    super.key,
    required this.image,
    required this.tags,
    required this.title,
    required this.description,
    required this.source,
    required this.heroTag,
  });

  @override
  State<NewsArticleScreen> createState() => _NewsArticleScreenState();
}

class _NewsArticleScreenState extends State<NewsArticleScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerAnimController;
  bool _isBookmarked = false;
  double _readProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max > 0) {
      setState(() {
        _readProgress = (_scrollController.offset / max).clamp(0.0, 1.0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyText = getArticleBody(widget.title);
    final paragraphs = bodyText.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF9),
      body: PopScope(
        canPop: true,
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Image
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Hero(
                        tag: widget.heroTag,
                        child: AspectRatio(
                          aspectRatio: isWide ? 21 / 9 : 16 / 10,
                          child: Image.asset(
                            widget.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFFE8E8E3),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay for legibility
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                Colors.transparent,
                                const Color(0xFFFAFAF9),
                              ],
                              stops: const [0.0, 0.35, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Article Body
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 48.0 : 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),

                            // Tags row
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.tags.map((tag) {
                                final cleaned = tag.replaceAll('•', '').trim();
                                final isTrending = cleaned.toLowerCase().contains('trending') ||
                                    cleaned.toLowerCase().contains('hot');
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isTrending
                                        ? const Color(0xFFFEF2F2)
                                        : const Color(0xFFF1F0ED),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isTrending
                                          ? const Color(0xFFFECACA)
                                          : const Color(0xFFE4E2DC),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isTrending) ...[
                                        const Icon(
                                          Icons.local_fire_department_rounded,
                                          size: 10,
                                          color: Color(0xFFEF4444),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        cleaned,
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isTrending
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF6B6B60),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Title
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A17),
                                height: 1.4,
                                letterSpacing: -0.1,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Meta row: source + read time
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.source,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '•',
                                  style: TextStyle(
                                    color: Color(0xFFA8A89A),
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.schedule, size: 10, color: Color(0xFFA8A89A)),
                                const SizedBox(width: 4),
                                const Text(
                                  '4 min read',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                    color: Color(0xFFA8A89A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Horizontal rule
                            const Divider(color: Color(0xFFE4E2DC), height: 1),
                            const SizedBox(height: 20),

                            // Lead / description
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Text(
                                widget.description,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E40AF),
                                  height: 1.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Article paragraphs
                            ...paragraphs.asMap().entries.map((entry) {
                              final i = entry.key;
                              final para = entry.value.trim();
                              // Every 3rd paragraph gets a subtle pull-quote treatment
                              if (i > 0 && i % 3 == 0) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                                    decoration: BoxDecoration(
                                      border: const Border(
                                        left: BorderSide(
                                          color: Color(0xFF0F172A),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      para,
                                      style: const TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A17),
                                        height: 1.7,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  para,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF3D3D35),
                                    height: 1.75,
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 24),
                            const Divider(color: Color(0xFFE4E2DC)),
                            const SizedBox(height: 16),

                            // Disclaimer footer
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFFA8A89A)),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'This article is for informational purposes only and does not constitute investment advice. Past performance is not indicative of future results.',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFA8A89A),
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Color(0xFF1A1A17),
                          ),
                        ),
                      ),

                      // Bookmark button
                      GestureDetector(
                        onTap: () {
                          setState(() => _isBookmarked = !_isBookmarked);
                          HapticFeedback.lightImpact();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _isBookmarked
                                ? const Color(0xFF1A1A17)
                                : Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 18,
                            color: _isBookmarked ? Colors.white : const Color(0xFF1A1A17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom reading progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _readProgress,
                backgroundColor: const Color(0xFFE4E2DC),
                color: const Color(0xFF2563EB),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
