import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/mock_videos.dart';
import '../../models/video_models.dart';

class VideosTab extends StatelessWidget {
  const VideosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: const Color(0xFF94A3B8), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // List of Video Modules
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: mockVideoModules.length,
                  itemBuilder: (context, index) {
                    final module = mockVideoModules[index];
                    return _buildVideoCard(context, module);
                  },
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                itemCount: mockVideoModules.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final module = mockVideoModules[index];
                  return _buildVideoCard(context, module);
                },
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(BuildContext context, VideoModule module) {
    return GestureDetector(
      onTap: () {
        context.push('/learnings/video-reader', extra: module);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Colored Flag with Triangle cut
              SizedBox(
                width: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // The light colored vertical bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        width: 16,
                        decoration: BoxDecoration(
                          color: module.flagColor.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    // The Play Triangle overlapping the right edge of the bar
                    Positioned(
                      left: 4,
                      child: Icon(
                        Icons.play_arrow,
                        color: module.flagColor,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${module.duration} • ${module.videoCount} Videos',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
