import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeWealthFeed extends StatefulWidget {
  final ScrollController scrollController;
  final ValueNotifier<bool>? isSecondCardStacked;

  const HomeWealthFeed({super.key, required this.scrollController, this.isSecondCardStacked});

  @override
  State<HomeWealthFeed> createState() => _HomeWealthFeedState();
}

class _HomeWealthFeedState extends State<HomeWealthFeed> {
  late Timer _timer;
  String _currentTimeIst = '';
  List<Map<String, dynamic>> _newsItems = [];
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
    _fetchNews();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    // Current time in UTC + 5:30 for IST
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    setState(() {
      _currentTimeIst = DateFormat('hh:mm a').format(now);
    });
  }

  Future<void> _fetchNews() async {
    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Changed cache key to force a fresh fetch with the new logic
      final cachedDate = await _storage.read(key: 'marketaux_fetch_date_v2');
      
      if (cachedDate == todayStr) {
        final cachedNewsStr = await _storage.read(key: 'marketaux_news_v2');
        if (cachedNewsStr != null) {
          final List<dynamic> decoded = jsonDecode(cachedNewsStr);
          setState(() {
            _newsItems = List<Map<String, dynamic>>.from(decoded);
            _isLoading = false;
          });
          return;
        }
      }

      final apiKey = dotenv.env['MARKETAUX_API_KEY'];
      if (apiKey == null) throw Exception('API Key not found');

      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );

      List<dynamic> allData = [];
      // Fetch up to 3 pages (if limit is 3 per page, this gives up to 9 articles)
      for (int page = 1; page <= 3; page++) {
        final response = await dio.get(
          'https://api.marketaux.com/v1/news/all',
          queryParameters: {
            'api_token': apiKey,
            'language': 'en',
            'countries': 'in,us',
            'search': 'law | regulation | market | trending',
            'page': page,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data['data'] as List<dynamic>;
          allData.addAll(data);
          // If we reached our goal or no more data, stop fetching
          if (allData.length >= 7 || data.isEmpty) break;
        } else {
          break; // Stop on API error
        }
      }

      if (allData.isNotEmpty) {
        // Enforce exactly 7 articles if we have more
        if (allData.length > 7) {
          allData = allData.sublist(0, 7);
        }

        final List<Map<String, dynamic>> parsedNews = allData.map((article) {
          List<String> tags = [];
          if (article['entities'] != null && (article['entities'] as List).isNotEmpty) {
            final entities = article['entities'] as List<dynamic>;
            for (var entity in entities) {
              if (entity['industry'] != null && !tags.contains(entity['industry'])) {
                tags.add(entity['industry']);
              } else if (entity['type'] != null && !tags.contains(entity['type'])) {
                tags.add(entity['type']);
              }
            }
          }
          List<String> finalTags = tags.isEmpty ? ['Top News'] : tags.take(2).toList();
          
          return {
            'image': article['image_url'] ?? 'lib/core/images/no_recurring_bg.webp',
            'tags': finalTags,
            'title': article['title'] ?? '',
            'description': article['description'] ?? article['snippet'] ?? '',
            'source': article['source'] ?? 'Marketaux',
          };
        }).toList();

        setState(() {
          _newsItems = parsedNews;
          _isLoading = false;
        });

        await _storage.write(key: 'marketaux_fetch_date_v2', value: todayStr);
        await _storage.write(key: 'marketaux_news_v2', value: jsonEncode(parsedNews));
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double scale = (MediaQuery.of(context).size.width / 393.0).clamp(0.8, 1.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your wealth feed',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 8 * scale),
              Row(
                children: [
                  Container(
                    width: 8 * scale,
                    height: 8 * scale,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E), // Green
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    'Last updated: Today, $_currentTimeIst',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24 * scale),
        
        // Feed
        if (_isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40 * scale),
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A))),
          )
        else if (_newsItems.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40 * scale),
            child: Center(
              child: Text(
                "No news available at the moment.",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14 * scale,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.0 * scale),
            itemCount: _newsItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 24 * scale),
            itemBuilder: (context, index) {
              final item = _newsItems[index];
              return _WealthFeedCard(
                imagePath: item['image'],
                tags: List<String>.from(item['tags']),
                title: item['title'],
                description: item['description'],
                source: item['source'],
                scrollController: widget.scrollController,
                index: index,
                isSecondCardStacked: widget.isSecondCardStacked,
              );
            },
          ),
      ],
    );
  }
}

class _WealthFeedCard extends StatefulWidget {
  final String imagePath;
  final List<String> tags;
  final String title;
  final String description;
  final String source;
  final ScrollController scrollController;
  final int index;
  final ValueNotifier<bool>? isSecondCardStacked;

  const _WealthFeedCard({
    required this.imagePath,
    required this.tags,
    required this.title,
    required this.description,
    required this.source,
    required this.scrollController,
    required this.index,
    this.isSecondCardStacked,
  });

  @override
  State<_WealthFeedCard> createState() => _WealthFeedCardState();
}

class _WealthFeedCardState extends State<_WealthFeedCard> {
  final GlobalKey _wrapperKey = GlobalKey();
  bool _isPressed = false;
  double? _absoluteY;
  double? _cardHeight;
  double _currentOverlap = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLayoutInfo();
    });
  }

  void _updateLayoutInfo() {
    if (!mounted) return;
    if (_wrapperKey.currentContext != null) {
      final box = _wrapperKey.currentContext!.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final double globalY = box.localToGlobal(Offset.zero).dy;
        final newAbsoluteY = globalY + widget.scrollController.offset;
        final newHeight = box.size.height;
        
        // Only update if significant layout change to avoid rebuild loops
        if (_absoluteY == null || (_absoluteY! - newAbsoluteY).abs() > 2.0 || _cardHeight != newHeight) {
          setState(() {
            _absoluteY = newAbsoluteY;
            _cardHeight = newHeight;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Keep layout metrics updated as long as we aren't pinned, handles image loading
      if (mounted && _currentOverlap < 10.0) _updateLayoutInfo();
    });

    double scale = (MediaQuery.of(context).size.width / 393.0).clamp(0.8, 1.2);
    final topSafeArea = MediaQuery.of(context).padding.top;
    final double pinOffset = topSafeArea + 90.0; // No stagger, stack perfectly on top

    return SizedBox(
      key: _wrapperKey,
      child: AnimatedBuilder(
        animation: widget.scrollController,
        builder: (context, child) {
          double overlap = 0.0;
          double scale = 1.0;
          double opacity = 1.0;

          if (_wrapperKey.currentContext != null && _absoluteY != null && _cardHeight != null) {
            // Calculate smooth Y position based purely on the controller's offset
            final double yPos = _absoluteY! - widget.scrollController.offset;
            
            double overlap = pinOffset - yPos;
            if (overlap < 0) overlap = 0.0; // Not pinned yet
            
            _currentOverlap = overlap; // Cache for post frame callback
            
            // The next card arrives when overlap equals this card's height + the 24px separator
            final double distanceToNextCard = (_cardHeight! + 24.0 * scale) - overlap;
            
            // Fade out the current card ONLY when the next one is right about to cover it
            if (distanceToNextCard < 60.0) {
              opacity = (distanceToNextCard / 60.0).clamp(0.0, 1.0);
            }
            
            // Notify if this is the second card
            if (widget.index == 1 && widget.isSecondCardStacked != null) {
              final bool currentlyStacked = overlap > 0;
              if (widget.isSecondCardStacked!.value != currentlyStacked) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    widget.isSecondCardStacked!.value = currentlyStacked;
                  }
                });
              }
            }
          }

          return Transform(
            transform: Matrix4.translationValues(0, _currentOverlap, 0),
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    double scale = (MediaQuery.of(context).size.width / 393.0).clamp(0.8, 1.2);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4 * scale),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                offset: const Offset(0, 4),
                blurRadius: 16 * scale,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(4 * scale)),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    color: const Color(0xFFF8FAFC), // subtle background for letterboxing
                    child: widget.imagePath.startsWith('http')
                        ? Image.network(
                            widget.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('lib/core/images/no_recurring_bg.webp', fit: BoxFit.cover),
                          )
                        : Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
               // Content Section
              Padding(
                padding: EdgeInsets.all(16.0 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags
                    Row(
                      children: widget.tags.map((tag) {
                        final isTrending = tag.toLowerCase().contains('trending') || tag.toLowerCase().contains('hot');
                        return Padding(
                          padding: EdgeInsets.only(right: 8.0 * scale),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4 * scale),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isTrending) ...[
                                  Icon(Icons.local_fire_department_rounded, size: 12 * scale, color: const Color(0xFFEF4444)),
                                  SizedBox(width: 4 * scale),
                                ],
                                Text(
                                  tag.replaceAll('•', '').trim(),
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: isTrending ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12 * scale),
                    
                    // Title
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    
                    // Description
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF475569),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16 * scale),
                    
                    // Footer (Source and Read More)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Source: ${widget.source}',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        
                        // Read More Button
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20 * scale),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Read summary',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 10 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(width: 4 * scale),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16 * scale,
                                color: const Color(0xFF0F172A),
                              ),
                            ],
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
    );
  }
}
