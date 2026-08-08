import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/video_models.dart';

class VideoReaderScreen extends StatefulWidget {
  final VideoModule module;

  const VideoReaderScreen({super.key, required this.module});

  @override
  State<VideoReaderScreen> createState() => _VideoReaderScreenState();
}

class _VideoReaderScreenState extends State<VideoReaderScreen> {
  int _currentVideoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildHeader(),
                            _buildVideoPlayer(),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: _buildPlaylist(),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildHeader(),
                    _buildVideoPlayer(),
                    Expanded(
                      child: _buildPlaylist(),
                    ),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(width: 16),
              Text(
                '${_currentVideoIndex + 1}/${widget.module.videos.length}',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const Icon(Icons.bookmark_border_rounded, size: 28, color: Color(0xFF0F172A)),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder Background
          Container(
            color: const Color(0xFFF1F5F9),
            child: Center(
              child: Text(
                widget.module.videos[_currentVideoIndex].title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          
          // YouTube Play Button
          Center(
            child: Container(
              width: 68,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // Share Button
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.reply_rounded, color: Colors.white, size: 24),
            ),
          ),

          // Watch on YouTube Pill
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Watch on',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.play_arrow, color: Color(0xFFFF0000), size: 12),
                        SizedBox(width: 2),
                        Text(
                          'YouTube',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
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
      ),
    );
  }

  Widget _buildPlaylist() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: widget.module.videos.length,
      itemBuilder: (context, index) {
        final chapter = widget.module.videos[index];
        final isActive = index == _currentVideoIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _currentVideoIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFEFFFF4) : Colors.transparent,
              border: isActive 
                ? const Border(left: BorderSide(color: Color(0xFF22C55E), width: 4))
                : null,
            ),
            child: Text(
              chapter.title,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        );
      },
    );
  }
}
