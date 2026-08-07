import 'package:flutter/material.dart';

class VideoModule {
  final String id;
  final String title;
  final String duration;
  final int videoCount;
  final Color flagColor;
  final List<VideoChapter> videos;

  const VideoModule({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoCount,
    required this.flagColor,
    required this.videos,
  });
}

class VideoChapter {
  final String id;
  final String title;
  final String videoUrl;

  const VideoChapter({
    required this.id,
    required this.title,
    required this.videoUrl,
  });
}
