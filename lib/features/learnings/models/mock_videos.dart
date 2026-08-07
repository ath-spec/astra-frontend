import 'package:flutter/material.dart';
import 'video_models.dart';

final List<VideoModule> mockVideoModules = [
  VideoModule(
    id: 'vmod_1',
    title: 'Introduction to Stock Markets',
    duration: '1 hr 10 min',
    videoCount: 10,
    flagColor: Colors.green.shade400,
    videos: const [
      VideoChapter(id: 'v1_1', title: '1. Why should you invest?', videoUrl: ''),
      VideoChapter(id: 'v1_2', title: '2. Market Intermediaries', videoUrl: ''),
      VideoChapter(id: 'v1_3', title: '3. Why and how do companies list, and what is an IPO?', videoUrl: ''),
      VideoChapter(id: 'v1_4', title: '4. Why do stock prices fluctuate?', videoUrl: ''),
      VideoChapter(id: 'v1_5', title: '5. How does a trading platform work?', videoUrl: ''),
      VideoChapter(id: 'v1_6', title: '6. What is a stock market index?', videoUrl: ''),
      VideoChapter(id: 'v1_7', title: '7. Clearing and settlement process', videoUrl: ''),
      VideoChapter(id: 'v1_8', title: '8. Understanding corporate actions like dividends, bonuses and buybacks', videoUrl: ''),
      VideoChapter(id: 'v1_9', title: '9. Order Types', videoUrl: ''),
      VideoChapter(id: 'v1_10', title: '10. Getting started', videoUrl: ''),
    ],
  ),
  VideoModule(
    id: 'vmod_2',
    title: 'Technical Analysis',
    duration: '2 hr 1 min',
    videoCount: 12,
    flagColor: Colors.redAccent.shade200,
    videos: List.generate(
      12,
      (i) => VideoChapter(
        id: 'v2_${i + 1}',
        title: '${i + 1}. Technical Analysis Chapter ${i + 1}',
        videoUrl: '',
      ),
    ),
  ),
  VideoModule(
    id: 'vmod_3',
    title: 'Fundamental Analysis',
    duration: '1 hr 5 min',
    videoCount: 10,
    flagColor: Colors.amber.shade300,
    videos: List.generate(
      10,
      (i) => VideoChapter(
        id: 'v3_${i + 1}',
        title: '${i + 1}. Fundamental Analysis Chapter ${i + 1}',
        videoUrl: '',
      ),
    ),
  ),
  VideoModule(
    id: 'vmod_4',
    title: 'Futures Trading',
    duration: '56 min',
    videoCount: 9,
    flagColor: Colors.deepPurple.shade300,
    videos: List.generate(
      9,
      (i) => VideoChapter(
        id: 'v4_${i + 1}',
        title: '${i + 1}. Futures Trading Chapter ${i + 1}',
        videoUrl: '',
      ),
    ),
  ),
  VideoModule(
    id: 'vmod_5',
    title: 'Options Trading',
    duration: '1 hr 11 min',
    videoCount: 11,
    flagColor: Colors.cyan.shade300,
    videos: List.generate(
      11,
      (i) => VideoChapter(
        id: 'v5_${i + 1}',
        title: '${i + 1}. Options Trading Chapter ${i + 1}',
        videoUrl: '',
      ),
    ),
  ),
];
